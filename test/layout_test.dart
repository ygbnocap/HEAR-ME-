import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/screens/start_screen.dart';
import 'package:hear_me/models/question_pack.dart';
import 'package:hear_me/screens/time_select_screen.dart';
import 'package:hear_me/screens/final_vote_screen.dart';

void main() {
  for (final remaining in [false, true]) {
    testWidgets('wide final vote background remaining=$remaining',
        (tester) async {
      const size = Size(1200, 900);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: FinalVoteScreen(
        accumulatedTime: 120,
        correctAnswers: 7,
        totalQuestions: 7,
        remainingEasyQuestions: remaining
            ? [
                const Question(
                    id: 'e', text: 'Вопрос', difficulty: Difficulty.easy)
              ]
            : [],
        remainingMediumQuestions: const [],
        remainingHardQuestions: const [],
      )));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(tester.getRect(find.byWidget(scaffold.body!)), Offset.zero & size);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('landscape final transition visible without scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(854, 392);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: FinalVoteScreen(
      accumulatedTime: 180,
      correctAnswers: 3,
      totalQuestions: 7,
      remainingEasyQuestions: [
        Question(id: 'e', text: 'Вопрос', difficulty: Difficulty.easy)
      ],
      remainingMediumQuestions: [],
      remainingHardQuestions: [],
    )));
    final action = find.widgetWithText(FilledButton, 'К ФИНАЛЬНОМУ РАУНДУ');
    expect(action.hitTestable(), findsOneWidget);
    expect(tester.getRect(action).bottom, lessThanOrEqualTo(392));
    expect(tester.takeException(), isNull);
  });
  testWidgets('wide time selection paints full viewport', (tester) async {
    const size = Size(960, 432);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: TimeSelectScreen()));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(tester.getRect(find.byWidget(scaffold.body!)), Offset.zero & size);
    expect(tester.takeException(), isNull);
  });
  testWidgets('wide start paints full viewport and centers content',
      (tester) async {
    const size = Size(960, 432);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: const StartScreen(),
    ));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final background = find.byWidget(scaffold.body!);
    expect(tester.getRect(background), Offset.zero & size);
    expect(tester.getCenter(find.text('КАК')).dx, closeTo(size.width / 2, 0.1));
    expect(
        tester.getCenter(find.text('НАЧАТЬ')).dx, closeTo(size.width / 2, 0.1));
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(568, 320), const Size(640, 360)]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('compact routes $size scale $scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Future<void> show(Widget screen) async {
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData.dark(useMaterial3: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: screen,
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }

        await show(const TimeSelectScreen());
        for (final label in ['1:00', '1:30', '2:00']) {
          await tester.ensureVisible(find.text(label));
          expect(find.text(label).hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await show(const StartScreen());
        await tester.ensureVisible(find.text('ПРАВИЛА'));
        await tester.tap(find.text('ПРАВИЛА'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byTooltip('Закрыть правила').hitTestable(), findsOneWidget);
        expect(tester.getSize(find.byTooltip('Закрыть правила')).shortestSide,
            greaterThanOrEqualTo(48));
        for (var page = 1; page < 8; page++) {
          await tester.tap(find.text('ДАЛЕЕ'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.text('ПОНЯТНО').hitTestable(), findsOneWidget);
        await tester.tap(find.byTooltip('Закрыть правила'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('НАЧАТЬ'));
        expect(find.text('НАЧАТЬ').hitTestable(), findsOneWidget);
        expect(tester.binding.hasScheduledFrame, isFalse);
        await show(const FinalVoteScreen(
          key: ValueKey('remaining'),
          accumulatedTime: 120,
          correctAnswers: 7,
          totalQuestions: 7,
          remainingEasyQuestions: [
            Question(id: 'e', text: 'Вопрос', difficulty: Difficulty.easy)
          ],
          remainingMediumQuestions: [],
          remainingHardQuestions: [],
        ));
        await tester.ensureVisible(find.text('К ФИНАЛЬНОМУ РАУНДУ'));
        expect(find.text('К ФИНАЛЬНОМУ РАУНДУ').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await show(const FinalVoteScreen(
          accumulatedTime: 120,
          correctAnswers: 7,
          totalQuestions: 7,
          remainingEasyQuestions: [],
          remainingMediumQuestions: [],
          remainingHardQuestions: [],
        ));
        await tester.ensureVisible(find.text('В ГЛАВНОЕ МЕНЮ'));
        expect(find.text('В ГЛАВНОЕ МЕНЮ').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
