// lib/services/pack_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/question_pack.dart';

class PackManager {
  static final PackManager _instance = PackManager._internal();
  factory PackManager() => _instance;
  PackManager._internal();

  final List<QuestionPack> _packs = [];
  List<QuestionPack> get packs => List.unmodifiable(_packs);

  QuestionPack? _selectedPack;
  QuestionPack? get selectedPack => _selectedPack;

  void selectPack(QuestionPack pack) => _selectedPack = pack;

  Future<void> loadAllPacks() async {
    _packs.clear();
    await _loadBuiltInPacks();
    await _loadUserPacks();
  }

  Future<void> _loadBuiltInPacks() async {
    const builtInPackFiles = [
      'assets/packs/built_in/default001.hmq',
      'assets/packs/built_in/warmup.hmq',
      'assets/packs/built_in/riddles_facts.hmq',
      'assets/packs/built_in/stars_screen.hmq',
      'assets/packs/built_in/odd_questions.hmq',
      'assets/packs/built_in/history_geo.hmq',
      'assets/packs/built_in/erudite.hmq',
      'assets/packs/built_in/default002.hmq',
      'assets/packs/built_in/default003.hmq',
      'assets/packs/built_in/default004.hmq',
    ];

    for (final path in builtInPackFiles) {
      try {
        final byteData = await rootBundle.load(path);
        final bytes = byteData.buffer.asUint8List();
        final content = utf8.decode(bytes);

        final pack = QuestionPack.fromHmqString(content);
        _packs.add(pack);
        debugPrint('Загружен пак: ${pack.name}');
      } catch (e) {
        debugPrint('Ошибка загрузки встроенного пака $path: $e');
      }
    }
  }

  Future<void> _loadUserPacks() async {
    final dir = await _getUserPacksDirectory();
    if (!await dir.exists()) return;

    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.hmq'));
    for (final file in files) {
      try {
        final content = await file.readAsString();
        final pack = QuestionPack.fromHmqString(content);
        _packs.add(pack);
        debugPrint('Загружен пользовательский пак: ${pack.name}');
      } catch (e) {
        debugPrint('Ошибка загрузки пользовательского пака ${file.path}: $e');
      }
    }
  }

  Future<ValidationResult> importPack(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return ValidationResult.invalid('Файл не найден');
    }

    String content;
    try {
      content = await file.readAsString();
    } catch (e) {
      return ValidationResult.invalid('Не удалось прочитать файл');
    }

    QuestionPack pack;
    try {
      pack = QuestionPack.fromHmqString(content);
    } catch (e) {
      return ValidationResult.invalid('Неверный формат .hmq файла');
    }

    if (!pack.isValid) {
      return ValidationResult.invalid(
        'Пак должен содержать минимум 4 вопроса каждой сложности\n'
            'Текущий: лёгких ${pack.easyQuestions.length}, '
            'средних ${pack.mediumQuestions.length}, '
            'сложных ${pack.hardQuestions.length}',
      );
    }

    final dir = await _getUserPacksDirectory();
    await dir.create(recursive: true);
    final newFile = File(p.join(dir.path, '${pack.id}.hmq'));
    await file.copy(newFile.path);

    _packs.add(pack);
    return ValidationResult.valid(pack);
  }

  Future<Directory> _getUserPacksDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, 'packs'));
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final QuestionPack? pack;

  const ValidationResult._(this.isValid, this.errorMessage, this.pack);

  factory ValidationResult.valid(QuestionPack pack) =>
      ValidationResult._(true, null, pack);

  factory ValidationResult.invalid(String message) =>
      ValidationResult._(false, message, null);
}