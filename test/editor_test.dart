import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/models/question_pack.dart';
import 'package:hear_me/services/pack_manager.dart';
import 'package:hear_me/screens/pack_select_screen.dart';
import 'package:hear_me/screens/pack_creator_screen.dart';
import 'package:hear_me/screens/question_edit_screen.dart';

class FakeManager implements PackManager {
  int loads = 0;
  Future<void> Function()? load;
  Future<ValidationResult> Function(String)? import;
  @override
  List<QuestionPack> get packs => [];
  @override
  QuestionPack? get selectedPack => null;
  @override
  void selectPack(QuestionPack pack) {}
  @override
  Future<void> loadAllPacks() async {
    loads++;
    await load?.call();
  }

  @override
  Future<ValidationResult> importPack(String path) async =>
      import == null ? ValidationResult.invalid('Ошибка') : await import!(path);
}

Future<void> mount(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}

Future<void> fillQuestions(WidgetTester tester) async {
  for (final tab in ['ЛЁГКИЕ', 'СРЕДНИЕ', 'СЛОЖНЫЕ']) {
    await tester.ensureVisible(find.text(tab));
    await tester.tap(find.text(tab));
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.ensureVisible(find.text('Вопрос не задан').first);
      await tester.tap(find.text('Вопрос не задан').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, ' Вопрос $tab $i ');
      await tester.enterText(find.byType(TextField).last, ' Ответ ');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
    }
  }
}

void main() {
  testWidgets('question header fits 568x320 at text scale 2', (tester) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
      data: MediaQueryData(
          size: Size(568, 320), textScaler: TextScaler.linear(2)),
      child: QuestionEditScreen(
          initialText: '', initialAnswer: '', questionNumber: 12),
    )));
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilledButton, 'Сохранить'), findsOneWidget);
  });

  testWidgets('creator write failure recovers and success returns once',
      (tester) async {
    final nav = GlobalKey<NavigatorState>();
    var writes = 0;
    bool? result;
    await mount(tester, const SizedBox());
    await tester.pumpWidget(MaterialApp(
        navigatorKey: nav, home: const Scaffold(body: Text('Home'))));
    nav.currentState!
        .push<bool>(MaterialPageRoute(
            builder: (_) => PackCreatorScreen(writePack: (_, __) async {
                  writes++;
                  if (writes == 1) throw Exception('private storage path');
                })))
        .then((value) => result = value);
    await tester.pumpAndSettle();
    await fillQuestions(tester);
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'Пак');
    await tester.pump();
    await tester.ensureVisible(find.text('СОХРАНИТЬ ПАК'));
    await tester.tap(find.text('СОХРАНИТЬ ПАК'));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось сохранить пак. Попробуйте ещё раз.'),
        findsOneWidget);
    expect(find.textContaining('private storage'), findsNothing);
    await tester.tap(find.text('СОХРАНИТЬ ПАК'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(writes, 2);
    expect(find.text('Home'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('import completion after disposal is safe', (tester) async {
    final pending = Completer<ValidationResult>();
    final manager = FakeManager()..import = (_) => pending.future;
    await mount(
        tester,
        PackSelectScreen(
            timeSeconds: 60,
            manager: manager,
            pickPath: () async => 'file.hmq'));
    await tester.tap(find.text('ЗАГРУЗИТЬ ПАК'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.completeError(Exception('storage'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('long import feedback wraps at double text scale',
      (tester) async {
    final manager = FakeManager()
      ..import = (_) async => ValidationResult.invalid(
          List.filled(40, 'Длинное русское сообщение').join(' '));
    await mount(
        tester,
        MediaQuery(
            data: const MediaQueryData(
                size: Size(1200, 800), textScaler: TextScaler.linear(2)),
            child: PackSelectScreen(
                timeSeconds: 60,
                manager: manager,
                pickPath: () async => 'file.hmq')));
    await tester.tap(find.text('ЗАГРУЗИТЬ ПАК'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('СОЗДАТЬ ПАК'), findsOneWidget);
  });

  testWidgets('name-last reactive validation and save latch survive disposal',
      (tester) async {
    final pending = Completer<void>();
    var writes = 0;
    String? content;
    await mount(tester, PackCreatorScreen(writePack: (name, json) {
      writes++;
      content = json;
      return pending.future;
    }));
    await fillQuestions(tester);
    GestureDetector save() => tester.widget<GestureDetector>(find
        .ancestor(
            of: find.text('СОХРАНИТЬ ПАК'),
            matching: find.byType(GestureDetector))
        .first);
    expect(save().onTap, isNull);
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'Пак');
    await tester.pump();
    expect(save().onTap, isNotNull);
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(save().onTap, isNull);
    await tester.enterText(find.byType(TextField).first, 'Пак');
    await tester.pump();
    final callback = save().onTap!;
    callback();
    callback();
    await tester.pump();
    expect(writes, 1);
    expect(content, contains('Пак'));
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Сохранение пака...'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    pending.completeError(Exception('write failed after unmount'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('selector load failure can retry', (tester) async {
    final manager = FakeManager()
      ..load = () async => throw Exception('private');
    await mount(tester, PackSelectScreen(timeSeconds: 60, manager: manager));
    expect(find.text('Повторить'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
    manager.load = () async {};
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(manager.loads, 2);
    expect(find.text('Повторить'), findsNothing);
  });

  testWidgets('load completion after disposal is safe', (tester) async {
    final pending = Completer<void>();
    final manager = FakeManager()..load = () => pending.future;
    await mount(tester, PackSelectScreen(timeSeconds: 60, manager: manager));
    await tester.pumpWidget(const SizedBox());
    pending.completeError(Exception('failure'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('picker completion after disposal is safe', (tester) async {
    final pending = Completer<String?>();
    final manager = FakeManager();
    await mount(
        tester,
        PackSelectScreen(
            timeSeconds: 60, manager: manager, pickPath: () => pending.future));
    await tester.tap(find.text('ЗАГРУЗИТЬ ПАК'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete('/unused.hmq');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel creator does not reload selector', (tester) async {
    final manager = FakeManager();
    await mount(tester, PackSelectScreen(timeSeconds: 60, manager: manager));
    await tester.tap(find.text('СОЗДАТЬ ПАК'));
    await tester.pumpAndSettle();
    expect(find.byType(PackCreatorScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(manager.loads, 1);
  });

  testWidgets('question dirty back keeps draft or discards explicitly',
      (tester) async {
    await mount(
        tester,
        const QuestionEditScreen(
            initialText: 'Вопрос', initialAnswer: 'Ответ', questionNumber: 1));
    await tester.enterText(find.byType(TextField).first, 'Изменение');
    await tester.tap(find.byTooltip('Назад'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить изменения?'), findsOneWidget);
    await tester.tap(find.text('Продолжить редактирование'));
    await tester.pumpAndSettle();
    expect(find.text('Изменение'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creator metadata marks draft dirty', (tester) async {
    await mount(tester, const PackCreatorScreen());
    await tester.enterText(find.byType(TextField).first, 'Новый пак');
    await tester.pump();
    await tester.ensureVisible(find.byTooltip('Назад'));
    await tester.tap(find.byTooltip('Назад'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить черновик?'), findsOneWidget);
    await tester.tap(find.text('Продолжить редактирование'));
    await tester.pumpAndSettle();
    expect(find.text('Новый пак'), findsOneWidget);
  });
}
