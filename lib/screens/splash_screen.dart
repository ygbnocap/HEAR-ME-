import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
import 'disclaimer_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _fadeTimer;
  Timer? _navigationTimer;
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late Animation<double> _gameFade;
  late Animation<double> _bothFadeOut;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
        duration: const Duration(milliseconds: 2500), vsync: this);
    _fadeOutController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _gameFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _fadeInController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut)));
    _bothFadeOut = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeInController.forward();
        _fadeTimer = Timer(const Duration(milliseconds: 3500), () {
          if (mounted) _fadeOutController.forward();
        });
        _navigationTimer = Timer(const Duration(milliseconds: 5000), () {
          if (mounted) _navigateToDisclaimer();
        });
      }
    });
  }

  void _navigateToDisclaimer() {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const DisclaimerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          reducedMotion
              ? child
              : FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 800),
    ));
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _navigationTimer?.cancel();
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StudioPage(
        center: true,
        maxWidth: 640,
        child: AnimatedBuilder(
            animation:
                Listenable.merge([_fadeInController, _fadeOutController]),
            builder: (context, child) => Opacity(
                  opacity: MediaQuery.disableAnimationsOf(context)
                      ? 1
                      : _gameFade.value * _bothFadeOut.value,
                  child:
                      const Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.headphones,
                        size: 64, color: GameplayTheme.primary),
                    SizedBox(height: 20),
                    Text('КАК СЛЫШНО?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: GameplayTheme.text)),
                  ]),
                )),
      );
}
