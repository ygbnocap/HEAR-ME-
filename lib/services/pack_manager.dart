// lib/services/pack_manager.dart
import 'dart:async';
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
  PackManager._internal()
      : _directoryProvider = _defaultDirectory,
        _builtInLoader = _defaultBuiltIns,
        _snapshotWriter = _writeSnapshot;

  @visibleForTesting
  PackManager.forTesting({
    required Future<Directory> Function() directoryProvider,
    required Future<List<QuestionPack>> Function() builtInLoader,
    Future<void> Function(File target, String content)? snapshotWriter,
  })  : _directoryProvider = directoryProvider,
        _builtInLoader = builtInLoader,
        _snapshotWriter = snapshotWriter ?? _writeSnapshot;

  final Future<Directory> Function() _directoryProvider;
  final Future<List<QuestionPack>> Function() _builtInLoader;
  final Future<void> Function(File target, String content) _snapshotWriter;
  Future<void> _pending = Future<void>.value();
  List<QuestionPack> _packs = [];
  List<QuestionPack> get packs => List.unmodifiable(_packs);
  QuestionPack? _selectedPack;
  QuestionPack? get selectedPack => _selectedPack;
  void selectPack(QuestionPack pack) => _selectedPack = pack;

  // A failed operation must not poison the queue for the next attempt.
  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> loadAllPacks() => _serialized(() async {
        try {
          final catalog = await _readCatalog(await _directoryProvider());
          _packs = catalog;
        } on FileSystemException {
          throw const FileSystemException('Не удалось загрузить паки');
        }
      });

  Future<List<QuestionPack>> _readCatalog(Directory dir) async {
    final catalog = <QuestionPack>[];
    final ids = <String>{};
    void admit(QuestionPack pack) {
      if (pack.isValid && ids.add(pack.id)) catalog.add(pack);
    }

    for (final pack in await _builtInLoader()) {
      admit(pack);
    }
    if (await dir.exists()) {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.hmq')) continue;
        try {
          admit(QuestionPack.fromHmqString(
              utf8.decode(await entity.readAsBytes())));
        } on FormatException {
          _diagnostic('invalid_json');
        } on TypeError {
          _diagnostic('invalid_schema');
        }
        // I/O failure aborts publication rather than silently losing inventory.
      }
    }
    return catalog;
  }

  Future<ValidationResult> importPack(String filePath) => _serialized(() async {
        try {
          final file = File(filePath);
          if (!await file.exists()) {
            return ValidationResult.invalid('Файл не найден');
          }
          // Keep exactly the snapshot that passed validation, never copy the source
          // again after asynchronous directory/catalog work.
          final content = await file.readAsString();
          final QuestionPack pack;
          try {
            pack = QuestionPack.fromHmqString(content);
          } on FormatException {
            return ValidationResult.invalid('Неверный формат .hmq файла');
          } on TypeError {
            return ValidationResult.invalid('Неверный формат .hmq файла');
          }
          if (!pack.isValid) {
            return ValidationResult.invalid(
              'Проверьте идентификатор, название, тексты и ответы пака. '
              'Нужно минимум 4 вопроса каждой сложности.',
            );
          }
          final dir = await _directoryProvider();
          await dir.create(recursive: true);
          final root = p.normalize(p.absolute(dir.path));
          final destination = p.normalize(p.join(root, '${pack.id}.hmq'));
          if (!p.isWithin(root, destination)) {
            return ValidationResult.invalid('Недопустимый идентификатор пака');
          }
          // Read disk too: creator filenames need not equal their logical IDs.
          final catalog = await _readCatalog(dir);
          if (catalog.any((existing) => existing.id == pack.id) ||
              await FileSystemEntity.type(destination, followLinks: false) !=
                  FileSystemEntityType.notFound) {
            return ValidationResult.invalid(
                'Пак с таким идентификатором уже существует');
          }
          final target = File(destination);
          // Exclusive creation prevents replacement if another writer wins the race.
          await target.create(exclusive: true);
          try {
            await _snapshotWriter(target, content);
          } on FileSystemException {
            // Only this operation's successfully reserved new file is rolled
            // back. A collision/create failure never reaches this cleanup.
            try {
              await target.delete();
            } on FileSystemException {
              _diagnostic('rollback_error');
            }
            rethrow;
          }
          _packs = [...catalog, pack];
          return ValidationResult.valid(pack);
        } on FormatException {
          return ValidationResult.invalid('Неверная кодировка .hmq файла');
        } on FileSystemException {
          _diagnostic('storage_error');
          return ValidationResult.invalid(
              'Не удалось прочитать или сохранить пак');
        }
      });

  static Future<void> _writeSnapshot(File target, String content) async {
    await target.writeAsString(content, flush: true);
  }

  static void _diagnostic(String code) {
    if (kDebugMode) debugPrint('PackManager: $code');
  }

  static Future<Directory> _defaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, 'packs'));
  }

  static Future<List<QuestionPack>> _defaultBuiltIns() async {
    const paths = [
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
    final packs = <QuestionPack>[];
    for (final path in paths) {
      try {
        final data = await rootBundle.load(path);
        packs.add(QuestionPack.fromHmqString(utf8.decode(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        )));
      } on FormatException {
        _diagnostic('invalid_builtin_json');
      } on TypeError {
        _diagnostic('invalid_builtin_schema');
      } on FlutterError {
        _diagnostic('unavailable_builtin');
      }
    }
    return packs;
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
