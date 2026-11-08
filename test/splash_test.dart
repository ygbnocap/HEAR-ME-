import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hear_me/screens/splash_screen.dart';
import 'package:hear_me/screens/disclaimer_screen.dart';
import 'package:hear_me/screens/start_screen.dart';

class RouteCounter extends NavigatorObserver {
  int replacements = 0;
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacements++;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  testWidgets('splash cancels timers on early disposal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('splash still advances after five seconds', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 3500));
    expect(find.byType(DisclaimerScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.byType(DisclaimerScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('manual disclaimer continuation near deadline navigates once',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final observer = RouteCounter();
    await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer], home: const DisclaimerScreen()));
    await tester.pump(const Duration(milliseconds: 6900));
    final gesture = tester.widget<GestureDetector>(find
        .ancestor(
            of: find.textContaining('ПРОДОЛЖИТЬ'),
            matching: find.byType(GestureDetector))
        .first);
    gesture.onTap!();
    gesture.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(observer.replacements, 1);
    expect(find.byType(StartScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
