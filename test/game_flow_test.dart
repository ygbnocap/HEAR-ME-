import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/models/question_pack.dart';
import 'package:hear_me/services/pack_manager.dart';
import 'package:hear_me/screens/game_screen.dart';
import 'package:hear_me/screens/final_game_screen.dart';
import 'package:hear_me/screens/final_vote_screen.dart';

List<Question> questions(Difficulty difficulty) => List.generate(
    4,
    (i) => Question(
        id: '$difficulty$i',
        text: 'Вопрос $i',
        answer: 'Ответ $i',
        difficulty: difficulty));
QuestionPack pack() => QuestionPack(
    id: 'test',
    name: 'Тест',
    easyQuestions: questions(Difficulty.easy),
    mediumQuestions: questions(Difficulty.medium),
    hardQuestions: questions(Difficulty.hard));
FinalGameScreen finalGame(int seconds) => FinalGameScreen(
    accumulatedTime: seconds,
    remainingEasyQuestions: questions(Difficulty.easy),
    remainingMediumQuestions: questions(Difficulty.medium),
    remainingHardQuestions: questions(Difficulty.hard));
Future<void> size(WidgetTester tester,
    [Size value = const Size(1200, 800)]) async {
  tester.view.physicalSize = value;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> select(WidgetTester tester, String category) async {
  await tester.tap(find.text(category));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

Future<void> round(WidgetTester tester, String category, bool correct) async {
  await select(tester, category);
  await tester.tap(find.text('ОТВЕТ'));
  await tester.pump();
  await tester.tap(find.text(correct ? 'ПРАВИЛЬНО' : 'НЕПРАВИЛЬНО'));
  await tester.pump();
}

void main() {
  testWidgets('queued category and result callbacks are idempotent',
      (tester) async {
    await size(tester);
    PackManager().selectPack(pack());
    await tester
        .pumpWidget(const MaterialApp(home: GameScreen(timeSeconds: 60)));
    final category = tester
        .widget<GestureDetector>(find
            .ancestor(
                of: find.text('ЛЁГКИЕ'), matching: find.byType(GestureDetector))
            .first)
        .onTap!;
    category();
    category();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.text('ОТВЕТ'));
    await tester.pump();
    final correct = tester
        .widget<GestureDetector>(find
            .ancestor(
                of: find.text('ПРАВИЛЬНО'),
                matching: find.byType(GestureDetector))
            .first)
        .onTap!;
    correct();
    correct();
    await tester.pump();
    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('Осталось 3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('all wrong journey enters one zero-time result safely',
      (tester) async {
    await size(tester);
    PackManager().selectPack(pack());
    await tester
        .pumpWidget(const MaterialApp(home: GameScreen(timeSeconds: 60)));
    for (var i = 0; i < 7; i++) {
      await round(tester, i < 4 ? 'ЛЁГКИЕ' : 'СРЕДНИЕ', false);
    }
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(FinalVoteScreen), findsOneWidget);
    await tester.tap(find.text('К ФИНАЛЬНОМУ РАУНДУ'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('ВРЕМЯ ВЫШЛО!'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('ВРЕМЯ ВЫШЛО!'), findsOneWidget);
    await tester.tap(find.text('В ГЛАВНОЕ МЕНЮ'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('ВРЕМЯ ВЫШЛО!'), findsNothing);
    expect(find.byType(FinalGameScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('mixed main scoring preserves 30 60 90 awards and seven rounds',
      (tester) async {
    await size(tester);
    PackManager().selectPack(pack());
    await tester
        .pumpWidget(const MaterialApp(home: GameScreen(timeSeconds: 60)));
    await round(tester, 'ЛЁГКИЕ', true);
    await round(tester, 'СРЕДНИЕ', true);
    await round(tester, 'СЛОЖНЫЕ', true);
    for (var i = 0; i < 4; i++) {
      await round(tester, i < 3 ? 'ЛЁГКИЕ' : 'СРЕДНИЕ', false);
    }
    await tester.pump(const Duration(seconds: 1));
    final vote = tester.widget<FinalVoteScreen>(find.byType(FinalVoteScreen));
    expect(vote.accumulatedTime, 180);
    expect(vote.correctAnswers, 3);
    expect(vote.totalQuestions, 7);
    expect(
        vote.remainingEasyQuestions.length +
            vote.remainingMediumQuestions.length +
            vote.remainingHardQuestions.length,
        5);
    await tester.pumpWidget(const SizedBox());
  });
  for (final isFinal in [false, true]) {
    testWidgets(
        '${isFinal ? 'final' : 'main'} countdown cancels at early unmount',
        (tester) async {
      await size(tester);
      PackManager().selectPack(pack());
      await tester.pumpWidget(MaterialApp(
          home: isFinal ? finalGame(30) : const GameScreen(timeSeconds: 60)));
      await tester.pump();
      await tester.tap(find.text('ЛЁГКИЕ'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('final timeout cannot be dismissed with system Back',
      (tester) async {
    await size(tester);
    await tester.pumpWidget(MaterialApp(home: finalGame(1)));
    await tester.pump();
    await select(tester, 'ЛЁГКИЕ');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ВРЕМЯ ВЫШЛО!'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('ВРЕМЯ ВЫШЛО!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('three completed finals stay terminal and use neutral copy',
      (tester) async {
    await size(tester);
    await tester.pumpWidget(MaterialApp(home: finalGame(30)));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      expect(find.text('${i + 1}/3'), findsOneWidget);
      await select(tester, 'ЛЁГКИЕ');
      await tester.tap(find.text('ОТВЕТ'));
      await tester.pump();
      await tester.tap(find.text('ДАЛЕЕ'));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ИГРА ЗАВЕРШЕНА!'), findsOneWidget);
    expect(find.textContaining('Завершено вопросов: 3 из 3.'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('4/3'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('ИГРА ЗАВЕРШЕНА!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('compact main and final question cards fit', (tester) async {
    await size(tester, const Size(568, 320));
    PackManager().selectPack(pack());
    for (final screen in <Widget>[
      const GameScreen(timeSeconds: 60),
      finalGame(30)
    ]) {
      await tester.pumpWidget(MaterialApp(
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!),
          home: screen));
      await tester.pump();
      await tester.ensureVisible(find.text('ЛЁГКИЕ'));
      expect(find.text('ЛЁГКИЕ').hitTestable(), findsOneWidget);
      await select(tester, 'ЛЁГКИЕ');
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('ОТВЕТ'));
      expect(find.text('ОТВЕТ').hitTestable(), findsOneWidget);
      await tester.tap(find.text('ОТВЕТ'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
