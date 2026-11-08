import 'package:flutter/material.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';

class QuestionEditScreen extends StatefulWidget {
  final String initialText;
  final String initialAnswer;
  final int questionNumber;
  const QuestionEditScreen(
      {super.key,
      required this.initialText,
      required this.initialAnswer,
      required this.questionNumber});
  @override
  State<QuestionEditScreen> createState() => _QuestionEditScreenState();
}

class _QuestionEditScreenState extends State<QuestionEditScreen> {
  late TextEditingController _textController;
  late TextEditingController _answerController;
  bool _allowPop = false;
  bool _confirming = false;
  bool get _dirty =>
      _textController.text != widget.initialText ||
      _answerController.text != widget.initialAnswer;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _answerController = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void dispose() {
    _textController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _requestExit() async {
    if (_confirming) return;
    if (_dirty) {
      _confirming = true;
      final discard = await showDialog<bool>(
          context: context,
          builder: (context) => StudioTheme(
                  child: AlertDialog(
                title: const Text('Удалить изменения?'),
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
    _finish();
  }

  void _finish([Map<String, String>? result]) {
    if (!mounted || _allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: _allowPop || !_dirty,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _requestExit();
        },
        child: StudioPage(
            maxWidth: 800,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudioHeader(
                      title: 'Вопрос ${widget.questionNumber}',
                      onBack: _requestExit),
                  Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => _finish({
                          'text': _textController.text.trim(),
                          'answer': _answerController.text.trim()
                        }),
                        child: const Text('Сохранить'),
                      )),
                  const SizedBox(height: 16),
                  TextField(
                      onChanged: (_) => setState(() {}),
                      controller: _textController,
                      style: const TextStyle(
                          fontSize: 16, color: GameplayTheme.text),
                      decoration: const InputDecoration(labelText: 'Вопрос'),
                      minLines: 2,
                      maxLines: 6),
                  const SizedBox(height: 16),
                  TextField(
                      onChanged: (_) => setState(() {}),
                      controller: _answerController,
                      style: const TextStyle(
                          fontSize: 16, color: GameplayTheme.text),
                      decoration: const InputDecoration(labelText: 'Ответ'),
                      minLines: 2,
                      maxLines: 5),
                ])),
      );
}
