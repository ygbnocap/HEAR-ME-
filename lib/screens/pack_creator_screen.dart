// lib/screens/pack_creator_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'start_screen.dart';
import '../models/question_pack.dart';
import 'question_edit_screen.dart';

class PackCreatorScreen extends StatefulWidget {
  const PackCreatorScreen({super.key});

  @override
  State<PackCreatorScreen> createState() => _PackCreatorScreenState();
}

class _PackCreatorScreenState extends State<PackCreatorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _version = '1.0';

  List<QuestionData> _easyQuestions = [];
  List<QuestionData> _mediumQuestions = [];
  List<QuestionData> _hardQuestions = [];

  QuestionData? _editingQuestion;
  Difficulty? _editingDifficulty;
  int? _editingIndex;

  bool _isSaving = false;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _initEmptyQuestions();
  }

  void _initEmptyQuestions() {
    _easyQuestions = List.generate(4, (index) => QuestionData(text: '', answer: ''));
    _mediumQuestions = List.generate(4, (index) => QuestionData(text: '', answer: ''));
    _hardQuestions = List.generate(4, (index) => QuestionData(text: '', answer: ''));
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
    if (_editingQuestion != null && _editingDifficulty != null && _editingIndex != null) {
      setState(() {
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
        ),
      ),
    ).then((result) {
      if (result != null && result is Map<String, String>) {
        _saveQuestion(result['text'] ?? '', result['answer'] ?? '');
      }
    });
  }

  bool _isPackComplete() {
    if (_nameController.text.isEmpty) return false;

    final allQuestions = [..._easyQuestions, ..._mediumQuestions, ..._hardQuestions];
    return allQuestions.every((q) => q.text.isNotEmpty && q.answer.isNotEmpty);
  }

  Future<void> _savePack() async {
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
        'author': _authorController.text.isNotEmpty ? _authorController.text : 'Пользователь',
        'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Создан в конструкторе',
        'version': _version,
        'easy': _easyQuestions.asMap().entries.map((entry) {
          return {
            'id': 'e_${timestamp}_${entry.key}',
            'text': entry.value.text,
            'answer': entry.value.answer
          };
        }).toList(),
        'medium': _mediumQuestions.asMap().entries.map((entry) {
          return {
            'id': 'm_${timestamp}_${entry.key}',
            'text': entry.value.text,
            'answer': entry.value.answer
          };
        }).toList(),
        'hard': _hardQuestions.asMap().entries.map((entry) {
          return {
            'id': 'h_${timestamp}_${entry.key}',
            'text': entry.value.text,
            'answer': entry.value.answer
          };
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(packJson);

      final appDir = await getApplicationDocumentsDirectory();
      final packsDir = Directory('${appDir.path}/packs');
      if (!await packsDir.exists()) {
        await packsDir.create(recursive: true);
      }

      final safeName = _nameController.text.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
      final fileName = '${safeName}_$packId.hmq';
      final file = File('${packsDir.path}/$fileName');
      await file.writeAsString(jsonString);

      if (mounted) {
        _showSuccess('Пак "${_nameController.text}" успешно сохранён!');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      _showError('Ошибка сохранения: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Difficulty _getDifficultyByTab() {
    switch (_currentTab) {
      case 0: return Difficulty.easy;
      case 1: return Difficulty.medium;
      default: return Difficulty.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: _isSaving
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 20),
                Text('Сохранение пака...', style: TextStyle(color: Colors.white)),
              ],
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: Responsive.getWidth(context, 0.04),
                  right: Responsive.getWidth(context, 0.04),
                  top: Responsive.getHeight(context, 0.015),
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.primary, AppColors.highlight],
                          ).createShader(bounds),
                          child: Text(
                            'КОНСТРУКТОР ПАКОВ',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, 24),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.getHeight(context, 0.01)),
                        Container(
                          width: Responsive.getWidth(context, 0.12),
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.highlight],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        SizedBox(height: Responsive.getHeight(context, 0.02)),
                        _buildInfoSection(context),
                        SizedBox(height: Responsive.getHeight(context, 0.02)),
                        _buildTabs(context),
                        SizedBox(height: Responsive.getHeight(context, 0.015)),
                        _buildQuestionsList(),
                        SizedBox(height: Responsive.getHeight(context, 0.02)),
                        _buildSaveButton(),
                        SizedBox(height: Responsive.getHeight(context, 0.015)),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: AppColors.muted),
                          label: Text(
                            'НАЗАД',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: Responsive.getFontSize(context, 14),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.getWidth(context, 0.03)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Название пака *',
              labelStyle: TextStyle(color: AppColors.muted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.muted.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(context, 0.02),
                vertical: Responsive.getHeight(context, 0.01),
              ),
            ),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.01)),
          TextField(
            controller: _authorController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Автор',
              labelStyle: TextStyle(color: AppColors.muted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.muted.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(context, 0.02),
                vertical: Responsive.getHeight(context, 0.01),
              ),
            ),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.01)),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Описание',
              labelStyle: TextStyle(color: AppColors.muted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.muted.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(context, 0.02),
                vertical: Responsive.getHeight(context, 0.01),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTab('ЛЁГКИЕ', 0, AppColors.accent),
          _buildTab('СРЕДНИЕ', 1, AppColors.secondary),
          _buildTab('СЛОЖНЫЕ', 2, AppColors.highlight),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, Color color) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.getHeight(context, 0.008)),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 12),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: isSelected ? color : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    List<QuestionData> currentQuestions;
    Color color;

    switch (_currentTab) {
      case 0:
        currentQuestions = _easyQuestions;
        color = AppColors.accent;
        break;
      case 1:
        currentQuestions = _mediumQuestions;
        color = AppColors.secondary;
        break;
      default:
        currentQuestions = _hardQuestions;
        color = AppColors.highlight;
    }

    final filledCount = currentQuestions.where((q) => q.text.isNotEmpty && q.answer.isNotEmpty).length;

    return Container(
      padding: EdgeInsets.all(Responsive.getWidth(context, 0.03)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопросы ($filledCount/4)',
                style: TextStyle(
                  color: color,
                  fontSize: Responsive.getFontSize(context, 13),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (filledCount < 4)
                Text(
                  'Заполните все 4 вопроса',
                  style: TextStyle(
                    color: AppColors.muted.withOpacity(0.6),
                    fontSize: Responsive.getFontSize(context, 9),
                  ),
                ),
            ],
          ),
          SizedBox(height: Responsive.getHeight(context, 0.008)),
          ...List.generate(4, (index) {
            final question = currentQuestions[index];
            final isFilled = question.text.isNotEmpty && question.answer.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.getHeight(context, 0.008)),
              child: GestureDetector(
                onTap: () => _editQuestion(_getDifficultyByTab(), index),
                child: Container(
                  padding: EdgeInsets.all(Responsive.getWidth(context, 0.02)),
                  decoration: BoxDecoration(
                    color: isFilled ? color.withOpacity(0.15) : AppColors.muted.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFilled ? color.withOpacity(0.4) : AppColors.muted.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isFilled ? color : AppColors.muted.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.getFontSize(context, 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.getWidth(context, 0.015)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.text.isEmpty ? 'Вопрос не задан' : question.text,
                              style: TextStyle(
                                color: isFilled ? Colors.white : AppColors.muted.withOpacity(0.6),
                                fontSize: Responsive.getFontSize(context, 12),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (question.text.isNotEmpty)
                              Text(
                                'Ответ: ${question.answer}',
                                style: TextStyle(
                                  color: AppColors.muted.withOpacity(0.5),
                                  fontSize: Responsive.getFontSize(context, 10),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: isFilled ? color : AppColors.muted.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final isComplete = _isPackComplete();

    return GestureDetector(
      onTap: isComplete ? _savePack : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: Responsive.getHeight(context, 0.01)),
        decoration: BoxDecoration(
          gradient: isComplete
              ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
              : LinearGradient(colors: [AppColors.muted.withOpacity(0.3), AppColors.muted.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isComplete
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, spreadRadius: 3)]
              : null,
        ),
        child: Center(
          child: Text(
            'СОХРАНИТЬ ПАК',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 15),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: isComplete ? Colors.white : AppColors.muted.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionData {
  String text;
  String answer;

  QuestionData({
    required this.text,
    required this.answer,
  });
}