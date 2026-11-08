import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/models/question_pack.dart';
import 'package:hear_me/screens/final_game_screen.dart';
import 'package:hear_me/screens/game_screen.dart';
import 'package:hear_me/services/pack_manager.dart';

List<Question> _questions(Difficulty difficulty, {bool longText = false}) =>
    List.generate(
      4,
      (index) => Question(
        id: '${difficulty.name}$index',
        text: longText
            ? List.filled(40, 'Длинный русский вопрос.').join(' ')
            : 'Вопрос $index',
        answer: longText
            ? List.filled(40, 'Подробный русский ответ.').join(' ')
            : 'Ответ $index',
        difficulty: difficulty,
      ),
    );

Future<void> _mount(WidgetTester tester, Size size, double scale, bool isFinal,
    {bool longText = false}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final easy = _questions(Difficulty.easy, longText: longText);
  final medium = _questions(Difficulty.medium);
  final hard = _questions(Difficulty.hard);
  PackManager().selectPack(QuestionPack(
    id: 'design-test',
    name: 'Проверка оформления',
    easyQuestions: easy,
    mediumQuestions: medium,
    hardQuestions: hard,
  ));
  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: isFinal
        ? FinalGameScreen(
            accumulatedTime: 180,
            remainingEasyQuestions: easy,
            remainingMediumQuestions: medium,
            remainingHardQuestions: hard,
          )
        : const GameScreen(timeSeconds: 60),
  ));
  await tester.pump();
}

void main() {
  for (final isFinal in [false, true]) {
    for (final size in [const Size(854, 392), const Size(952, 427)]) {
      testWidgets('categories visible with spacing final=$isFinal size=$size',
          (tester) async {
        await _mount(tester, size, 1, isFinal);
        final rects = <Rect>[];
        for (final difficulty in Difficulty.values) {
          final finder =
              find.byKey(ValueKey('gameplay-category-${difficulty.name}'));
          expect(finder, findsOneWidget);
          expect(finder.hitTestable(), findsOneWidget);
          final rect = tester.getRect(finder);
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
          expect(rect.width, greaterThanOrEqualTo(48));
          expect(rect.height, greaterThanOrEqualTo(48));
          rects.add(rect);
        }
        for (var i = 0; i < rects.length; i++) {
          for (var j = i + 1; j < rects.length; j++) {
            // At least 12 logical pixels between independent tap regions.
            expect(
                rects[i].inflate(5.9).overlaps(rects[j].inflate(5.9)), isFalse);
          }
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'long question and answer actions reachable final=$isFinal scale=$scale',
          (tester) async {
        await _mount(tester, const Size(568, 320), scale, isFinal,
            longText: true);
        final category = find.byKey(const ValueKey('gameplay-category-easy'));
        await tester.ensureVisible(category);
        await tester.tap(category);
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        expect(find.byKey(const ValueKey('gameplay-question')), findsOneWidget);
        expect(
            tester
                .widget<Material>(
                    find.byKey(const ValueKey('gameplay-question-paper')))
                .color,
            Colors.white);
        expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('gameplay-question')))
                .style
                ?.color,
            const Color(0xFF17222B));
        expect(tester.takeException(), isNull);
        final answer = find.text('ОТВЕТ');
        await tester.ensureVisible(answer);
        expect(answer.hitTestable(), findsOneWidget);
        await tester.tap(answer);
        await tester.pump();
        expect(find.byKey(const ValueKey('gameplay-answer')), findsOneWidget);
        expect(
            tester
                .widget<Material>(
                    find.byKey(const ValueKey('gameplay-question-paper')))
                .color,
            Colors.white);
        expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('gameplay-answer')))
                .style
                ?.color,
            const Color(0xFF17222B));
        final next = find.text(isFinal ? 'ДАЛЕЕ' : 'ПРАВИЛЬНО');
        await tester.ensureVisible(next);
        expect(next.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(next);
        await tester.pump();
        expect(find.byKey(const ValueKey('gameplay-category-easy')),
            findsOneWidget);
        expect(find.text(isFinal ? '2/3' : '1/7'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });
    }
    testWidgets('large text categories remain reachable final=$isFinal',
        (tester) async {
      await _mount(tester, const Size(568, 320), 2, isFinal);
      for (final difficulty in Difficulty.values) {
        final finder =
            find.byKey(ValueKey('gameplay-category-${difficulty.name}'));
        await tester.ensureVisible(finder);
        await tester.pump();
        expect(finder.hitTestable(), findsOneWidget);
        expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
