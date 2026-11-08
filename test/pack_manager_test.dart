import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/models/question_pack.dart';
import 'package:hear_me/services/pack_manager.dart';
import 'question_pack_test.dart' show fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late Directory packs;
  late PackManager manager;
  Future<File> source(String id, {String name = 'Пак'}) async {
    final file = File('${temp.path}/input.hmq');
    return file.writeAsString(jsonEncode(fixture(id: id, name: name)));
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('hear_me_security_');
    packs = Directory('${temp.path}/packs');
    manager = PackManager.forTesting(
      directoryProvider: () async => packs,
      builtInLoader: () async => [],
    );
  });
  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test(
      'public singleton is shared and rejects missing input without storage access',
      () async {
    expect(identical(PackManager(), PackManager()), isTrue);
    final before = PackManager().packs;
    final result = await PackManager().importPack('${temp.path}/missing.hmq');
    expect(result.isValid, isFalse);
    expect(PackManager().packs, before);
  });
  test('partial failed write rolls back new target and permits retry',
      () async {
    var fail = true;
    manager = PackManager.forTesting(
      directoryProvider: () async => packs,
      builtInLoader: () async =>
          [QuestionPack.fromJson(fixture(id: 'builtin'))],
      snapshotWriter: (target, content) async {
        if (fail) {
          await target.writeAsString('partial');
          throw const FileSystemException('synthetic disk full');
        }
        await target.writeAsString(content, flush: true);
      },
    );
    await manager.loadAllPacks();
    final file = await source('retry');
    expect((await manager.importPack(file.path)).isValid, isFalse);
    expect(await File('${packs.path}/retry.hmq').exists(), isFalse);
    expect(manager.packs.map((p) => p.id), ['builtin']);
    fail = false;
    expect((await manager.importPack(file.path)).isValid, isTrue);
    expect(manager.packs.map((p) => p.id), ['builtin', 'retry']);
  });
  test('write rollback never removes preexisting collision', () async {
    await packs.create();
    final target =
        await File('${packs.path}/occupied.hmq').writeAsString('keep');
    var writes = 0;
    manager = PackManager.forTesting(
      directoryProvider: () async => packs,
      builtInLoader: () async => [],
      snapshotWriter: (target, content) async {
        writes++;
        throw const FileSystemException('synthetic disk full');
      },
    );
    expect((await manager.importPack((await source('occupied')).path)).isValid,
        isFalse);
    expect(writes, 0);
    expect(await target.readAsString(), 'keep');
  });
  test('valid import persists snapshot and survives reload', () async {
    final file = await source('valid');
    final content = await file.readAsString();
    expect((await manager.importPack(file.path)).isValid, isTrue);
    expect(await File('${packs.path}/valid.hmq').readAsString(), content);
    await manager.loadAllPacks();
    expect(manager.packs.single.id, 'valid');
  });
  test('traversal cannot touch outside sentinel', () async {
    final sentinel =
        await File('${temp.path}/outside.hmq').writeAsString('keep');
    final file = await source('../outside');
    expect((await manager.importPack(file.path)).isValid, isFalse);
    expect(await sentinel.readAsString(), 'keep');
    expect(manager.packs, isEmpty);
  });
  test('concurrent same-ID imports reject collision and preserve original',
      () async {
    final file = await source('duplicate');
    final results = await Future.wait([
      manager.importPack(file.path),
      manager.importPack(file.path),
    ]);
    expect(results.where((r) => r.isValid).length, 1);
    final before = await File('${packs.path}/duplicate.hmq').readAsString();
    await source('duplicate', name: 'Replacement');
    expect((await manager.importPack(file.path)).isValid, isFalse);
    expect(await File('${packs.path}/duplicate.hmq').readAsString(), before);
    expect(manager.packs.length, 1);
  });
  test('creator-style filenames and built-in IDs also collide', () async {
    await packs.create();
    await File('${packs.path}/title_custom.hmq').writeAsString(
      jsonEncode(fixture(id: 'custom')),
    );
    expect((await manager.importPack((await source('custom')).path)).isValid,
        isFalse);
    manager = PackManager.forTesting(
      directoryProvider: () async => packs,
      builtInLoader: () async =>
          [QuestionPack.fromJson(fixture(id: 'builtin'))],
    );
    expect((await manager.importPack((await source('builtin')).path)).isValid,
        isFalse);
  });
  test('existing invalid destination is never replaced', () async {
    await packs.create();
    final target =
        await File('${packs.path}/occupied.hmq').writeAsString('invalid');
    expect((await manager.importPack((await source('occupied')).path)).isValid,
        isFalse);
    expect(await target.readAsString(), 'invalid');
  });
  test('invalid neighbors skipped consistently without deleting files',
      () async {
    await packs.create();
    await File('${packs.path}/good.hmq')
        .writeAsString(jsonEncode(fixture(id: 'good')));
    await File('${packs.path}/bad.hmq').writeAsString('{');
    await File('${packs.path}/blank.hmq')
        .writeAsString(jsonEncode(fixture(name: ' ')));
    await File('${packs.path}/utf8.hmq').writeAsBytes([0xff, 0xfe]);
    await manager.loadAllPacks();
    expect(manager.packs.map((p) => p.id), ['good']);
    expect(await File('${packs.path}/bad.hmq').exists(), isTrue);
  });
  test('malformed UTF8 and missing source return invalid', () async {
    final file = await File('${temp.path}/bad.hmq').writeAsBytes([0xff]);
    expect((await manager.importPack(file.path)).isValid, isFalse);
    expect((await manager.importPack('${temp.path}/missing')).isValid, isFalse);
  });
  test('storage failures preserve catalog and queue recovers', () async {
    var fail = false;
    manager = PackManager.forTesting(
      directoryProvider: () async {
        if (fail) throw const FileSystemException('synthetic marker');
        return packs;
      },
      builtInLoader: () async =>
          [QuestionPack.fromJson(fixture(id: 'builtin'))],
    );
    await manager.loadAllPacks();
    fail = true;
    await expectLater(
        manager.loadAllPacks(), throwsA(isA<FileSystemException>()));
    expect(manager.packs.single.id, 'builtin');
    expect((await manager.importPack((await source('new')).path)).isValid,
        isFalse);
    fail = false;
    expect(
        (await manager.importPack((await source('new')).path)).isValid, isTrue);
  });
  test(
      'load publication is atomic; queued load/import neither duplicate nor lose data',
      () async {
    final gate = Completer<void>();
    var calls = 0;
    manager = PackManager.forTesting(
      directoryProvider: () async => packs,
      builtInLoader: () async {
        calls++;
        if (calls == 2) await gate.future;
        return [QuestionPack.fromJson(fixture(id: 'builtin'))];
      },
    );
    await manager.loadAllPacks();
    final file = await source('new');
    final load = manager.loadAllPacks();
    final secondLoad = manager.loadAllPacks();
    final importing = manager.importPack(file.path);
    await Future<void>.delayed(Duration.zero);
    expect(manager.packs.single.id, 'builtin');
    expect(calls, 2);
    gate.complete();
    await Future.wait([load, secondLoad]);
    expect((await importing).isValid, isTrue);
    expect(manager.packs.map((p) => p.id), ['builtin', 'new']);
  });
  test('invalid built-ins and duplicate logical IDs are not admitted',
      () async {
    manager = PackManager.forTesting(
      directoryProvider: () async => packs,
      builtInLoader: () async => [
        QuestionPack.fromJson(fixture(id: 'builtin')),
        QuestionPack.fromJson(fixture(id: 'builtin')),
        QuestionPack.fromJson(fixture(id: 'invalid', name: ' ')),
      ],
    );
    await manager.loadAllPacks();
    expect(manager.packs.map((p) => p.id), ['builtin']);
  });
  test('diagnostics never include imported names or malformed content',
      () async {
    await packs.create();
    await File('${packs.path}/synthetic_secret_marker.hmq')
        .writeAsString('{synthetic_secret_marker');
    final messages = <String?>[];
    final previous = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => messages.add(message);
    try {
      await manager.loadAllPacks();
      expect(messages, isNotEmpty);
      expect(messages.join(), isNot(contains('synthetic_secret_marker')));
      expect(messages.join(), isNot(contains(temp.path)));
    } finally {
      debugPrint = previous;
    }
  });
  test('source mutation after validation cannot change persisted snapshot',
      () async {
    final file = await source('snapshot');
    final original = await file.readAsString();
    manager = PackManager.forTesting(
      directoryProvider: () async {
        await file.writeAsString('changed after validation');
        return packs;
      },
      builtInLoader: () async => [],
    );
    expect((await manager.importPack(file.path)).isValid, isTrue);
    expect(await File('${packs.path}/snapshot.hmq').readAsString(), original);
  });
}
