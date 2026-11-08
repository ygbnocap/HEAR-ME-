import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/screens/disclaimer_screen.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('disclaimer centered title and bottom action scale=$scale',
        (tester) async {
      tester.view.physicalSize = const Size(854, 392);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: const DisclaimerScreen(),
      ));
      final title = find.text('ДИСКЛЕЙМЕР');
      expect(tester.widget<Text>(title).textAlign, TextAlign.center);
      expect(tester.getCenter(title).dx, closeTo(427, 0.1));
      final body = find.textContaining('Концепт игры');
      final button = find.byType(FilledButton);
      expect(
          tester.getRect(button).top, greaterThan(tester.getRect(body).bottom));
      expect(tester.getCenter(button).dx, closeTo(427, 0.1));
      await tester.ensureVisible(button);
      expect(button.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
