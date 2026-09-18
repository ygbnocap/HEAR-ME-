// lib/screens/question_edit_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuestionEditScreen extends StatefulWidget {
  final String initialText;
  final String initialAnswer;
  final int questionNumber;

  const QuestionEditScreen({
    super.key,
    required this.initialText,
    required this.initialAnswer,
    required this.questionNumber,
  });

  @override
  State<QuestionEditScreen> createState() => _QuestionEditScreenState();
}

class _QuestionEditScreenState extends State<QuestionEditScreen> {
  late TextEditingController _textController;
  late TextEditingController _answerController;

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
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Вопрос ${widget.questionNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'text': _textController.text,
                          'answer': _answerController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: const Size(80, 36),
                      ),
                      child: const Text('Сохранить', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.muted, height: 0),
              // Контент с возможностью скролла
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: const InputDecoration(
                          labelText: 'Вопрос',
                          labelStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.muted),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _answerController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: const InputDecoration(
                          labelText: 'Ответ',
                          labelStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.muted),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}