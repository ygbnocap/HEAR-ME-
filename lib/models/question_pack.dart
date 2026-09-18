// lib/models/question_pack.dart
import 'dart:convert';

enum Difficulty { easy, medium, hard }

class Question {
  final String id;
  final String text;
  final String? answer; // Добавляем поле для ответа (опционально)
  final Difficulty difficulty;

  const Question({
    required this.id,
    required this.text,
    this.answer,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json, Difficulty diff) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      answer: json['answer'] as String?, // Читаем ответ из JSON
      difficulty: diff,
    );
  }
}

class QuestionPack {
  final String id;
  final String name;
  final String? author;
  final String? description;
  final String version;
  final List<Question> easyQuestions;
  final List<Question> mediumQuestions;
  final List<Question> hardQuestions;

  const QuestionPack({
    required this.id,
    required this.name,
    this.author,
    this.description,
    this.version = '1.0',
    required this.easyQuestions,
    required this.mediumQuestions,
    required this.hardQuestions,
  });

  List<Question> get allQuestions => [
    ...easyQuestions,
    ...mediumQuestions,
    ...hardQuestions,
  ];

  bool get isValid =>
      easyQuestions.length >= 4 &&
          mediumQuestions.length >= 4 &&
          hardQuestions.length >= 4;

  factory QuestionPack.fromJson(Map<String, dynamic> json) {
    return QuestionPack(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      version: json['version'] as String? ?? '1.0',
      easyQuestions: (json['easy'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>, Difficulty.easy))
          .toList(),
      mediumQuestions: (json['medium'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>, Difficulty.medium))
          .toList(),
      hardQuestions: (json['hard'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>, Difficulty.hard))
          .toList(),
    );
  }

  factory QuestionPack.fromHmqString(String content) {
    final json = jsonDecode(content) as Map<String, dynamic>;
    return QuestionPack.fromJson(json);
  }
}