import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
import '../models/question_pack.dart';
import 'question_edit_screen.dart';

class PackCreatorScreen extends StatefulWidget {
  final Future<void> Function(String fileName, String content)? writePack;
  const PackCreatorScreen({super.key, this.writePack});
  @override
  State<PackCreatorScreen> createState() => _PackCreatorScreenState();
}

class _PackCreatorScreenState extends State<PackCreatorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String _version = '1.0';
  List<QuestionData> _easyQuestions = [];
  List<QuestionData> _mediumQuestions = [];
  List<QuestionData> _hardQuestions = [];
  QuestionData? _editingQuestion;
  Difficulty? _editingDifficulty;
  int? _editingIndex;
  bool _isSaving = false;
  int _currentTab = 0;
  bool _dirty = false;
  bool _allowPop = false;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _initEmptyQuestions();
    _nameController.addListener(_metadataChanged);
    _authorController.addListener(_metadataChanged);
    _descriptionController.addListener(_metadataChanged);
  }

  void _metadataChanged() => setState(() => _dirty = true);
  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _requestExit() async {
    if (_isSaving || _confirming) return;
    if (_dirty) {
      _confirming = true;
      final discard = await showDialog<bool>(
          context: context,
          builder: (context) => StudioTheme(
                  child: AlertDialog(
                title: const Text('Удалить черновик?'),
                content: const Text('Несохранённые изменения будут потеряны.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Продолжить редактирование')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Выйти')),
                ],
              )));
      _confirming = false;
      if (!mounted || discard != true) return;
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _initEmptyQuestions() {
    _easyQuestions =
        List.generate(4, (index) => QuestionData(text: '', answer: ''));
    _mediumQuestions =
        List.generate(4, (index) => QuestionData(text: '', answer: ''));
    _hardQuestions =
        List.generate(4, (index) => QuestionData(text: '', answer: ''));
  }

  void _editQuestion(Difficulty difficulty, int index) {
    setState(() {
      _editingDifficulty = difficulty;
      _editingIndex = index;
      if (difficulty == Difficulty.easy) {
        _editingQuestion = _easyQuestions[index];
      } else if (difficulty == Difficulty.medium) {
        _editingQuestion = _mediumQuestions[index];
      } else {
        _editingQuestion = _hardQuestions[index];
      }
    });
    _showQuestionDialog();
  }

  void _saveQuestion(String text, String answer) {
    if (_editingQuestion != null &&
        _editingDifficulty != null &&
        _editingIndex != null) {
      setState(() {
        _dirty = true;
        _editingQuestion!.text = text;
        _editingQuestion!.answer = answer;
        if (_editingDifficulty == Difficulty.easy) {
          _easyQuestions[_editingIndex!] = _editingQuestion!;
        } else if (_editingDifficulty == Difficulty.medium) {
          _mediumQuestions[_editingIndex!] = _editingQuestion!;
        } else {
          _hardQuestions[_editingIndex!] = _editingQuestion!;
        }
        _editingQuestion = null;
        _editingDifficulty = null;
        _editingIndex = null;
      });
    }
  }

  void _showQuestionDialog() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuestionEditScreen(
                  initialText: _editingQuestion?.text ?? '',
                  initialAnswer: _editingQuestion?.answer ?? '',
                  questionNumber: (_editingIndex ?? 0) + 1,
                ))).then((result) {
      if (mounted && result is Map<String, String>) {
        _saveQuestion(result['text'] ?? '', result['answer'] ?? '');
      }
    });
  }

  bool _isPackComplete() {
    if (_nameController.text.trim().isEmpty) return false;
    return [..._easyQuestions, ..._mediumQuestions, ..._hardQuestions]
        .every((q) => q.text.trim().isNotEmpty && q.answer.trim().isNotEmpty);
  }

  Future<void> _savePack() async {
    if (_isSaving || _allowPop) return;
    if (!_isPackComplete()) {
      _showError('Заполните все поля (название пака и все вопросы с ответами)');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final packId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final packJson = {
        'id': packId,
        'name': _nameController.text,
        'author': _authorController.text.isNotEmpty
            ? _authorController.text
            : 'Пользователь',
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Создан в конструкторе',
        'version': _version,
        'easy': _easyQuestions
            .asMap()
            .entries
            .map((entry) => {
                  'id': 'e_${timestamp}_${entry.key}',
                  'text': entry.value.text,
                  'answer': entry.value.answer
                })
            .toList(),
        'medium': _mediumQuestions
            .asMap()
            .entries
            .map((entry) => {
                  'id': 'm_${timestamp}_${entry.key}',
                  'text': entry.value.text,
                  'answer': entry.value.answer
                })
            .toList(),
        'hard': _hardQuestions
            .asMap()
            .entries
            .map((entry) => {
                  'id': 'h_${timestamp}_${entry.key}',
                  'text': entry.value.text,
                  'answer': entry.value.answer
                })
            .toList(),
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(packJson);
      final safeName = _nameController.text
          .trim()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(' ', '_');
      final fileName = '${safeName}_$packId.hmq';
      if (widget.writePack != null) {
        await widget.writePack!(fileName, jsonString);
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final packsDir = Directory('${appDir.path}/packs');
        if (!await packsDir.exists()) await packsDir.create(recursive: true);
        final file = File('${packsDir.path}/$fileName');
        await file.writeAsString(jsonString);
      }
      if (!mounted) return;
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    } catch (_) {
      if (mounted) _showError('Не удалось сохранить пак. Попробуйте ещё раз.');
    } finally {
      if (mounted && !_allowPop) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message,
              style: const TextStyle(color: GameplayTheme.onPrimary)),
          backgroundColor: GameplayTheme.error));

  int _filled(List<QuestionData> questions) => questions
      .where((q) => q.text.trim().isNotEmpty && q.answer.trim().isNotEmpty)
      .length;

  @override
  Widget build(BuildContext context) {
    final groups = [_easyQuestions, _mediumQuestions, _hardQuestions];
    final total = groups.fold<int>(0, (sum, group) => sum + _filled(group));
    return PopScope(
      canPop: _allowPop || (!_dirty && !_isSaving),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: StudioPage(
          child: _isSaving
              ? const Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Сохранение пака...',
                      style: TextStyle(fontSize: 16, color: GameplayTheme.text))
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      StudioHeader(
                          title: 'КОНСТРУКТОР ПАКОВ', onBack: _requestExit),
                      Text('Готово вопросов: $total/12',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: GameplayTheme.primary)),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: (context, constraints) {
                        final info = _buildInfoSection();
                        final questions = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                for (var index = 0; index < 3; index++)
                                  Semantics(
                                      selected: _currentTab == index,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            backgroundColor:
                                                _currentTab == index
                                                    ? GameplayTheme.raised
                                                    : GameplayTheme.surface,
                                            side: BorderSide(
                                                color: _currentTab == index
                                                    ? GameplayTheme.primary
                                                    : GameplayTheme.outline)),
                                        onPressed: () =>
                                            setState(() => _currentTab = index),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(const [
                                                'ЛЁГКИЕ',
                                                'СРЕДНИЕ',
                                                'СЛОЖНЫЕ'
                                              ][index]),
                                              Text(
                                                  '${_filled(groups[index])}/4',
                                                  style: const TextStyle(
                                                      fontSize: 14))
                                            ]),
                                      )),
                              ]),
                              const SizedBox(height: 12),
                              _buildQuestionsList(groups[_currentTab]),
                            ]);
                        if (constraints.maxWidth >= 800 &&
                            MediaQuery.textScalerOf(context).scale(16) <= 22) {
                          return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: info),
                                const SizedBox(width: 24),
                                Expanded(flex: 3, child: questions)
                              ]);
                        }
                        return Column(children: [
                          info,
                          const SizedBox(height: 24),
                          questions
                        ]);
                      }),
                      const SizedBox(height: 16),
                      if (!_isPackComplete()) ...[
                        const Text(
                            'Заполните все поля (название пака и все вопросы с ответами)',
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: GameplayTheme.secondary)),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                          onPressed: _isPackComplete() ? _savePack : null,
                          child: const Text('СОХРАНИТЬ ПАК')),
                    ])),
    );
  }

  Widget _buildInfoSection() =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 16, color: GameplayTheme.text),
            decoration: const InputDecoration(labelText: 'Название пака *')),
        const SizedBox(height: 16),
        TextField(
            controller: _authorController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 16, color: GameplayTheme.text),
            decoration: const InputDecoration(
                labelText: 'Автор', helperText: 'Необязательно')),
        const SizedBox(height: 16),
        TextField(
            controller: _descriptionController,
            style: const TextStyle(fontSize: 16, color: GameplayTheme.text),
            decoration: const InputDecoration(
                labelText: 'Описание', helperText: 'Необязательно'),
            minLines: 1,
            maxLines: 3),
      ]);

  Widget _buildQuestionsList(List<QuestionData> questions) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Вопросы (${_filled(questions)}/4)',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: GameplayTheme.text)),
        if (_filled(questions) < 4)
          const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Заполните все 4 вопроса',
                  style:
                      TextStyle(fontSize: 14, color: GameplayTheme.secondary))),
        const SizedBox(height: 12),
        for (var index = 0; index < 4; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: GameplayTheme.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                  button: true,
                  child: InkWell(
                      onTap: () =>
                          _editQuestion(Difficulty.values[_currentTab], index),
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            Text('${index + 1}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: GameplayTheme.primary)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      questions[index].text.isEmpty
                                          ? 'Вопрос не задан'
                                          : questions[index].text,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: GameplayTheme.text)),
                                  if (questions[index].text.isNotEmpty)
                                    Text('Ответ: ${questions[index].answer}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: GameplayTheme.secondary)),
                                ])),
                            const SizedBox(width: 12),
                            const Icon(Icons.edit_outlined,
                                size: 24, color: GameplayTheme.secondary),
                          ])))),
            ),
          ),
      ]);
}

class QuestionData {
  String text;
  String answer;
  QuestionData({required this.text, required this.answer});
}
