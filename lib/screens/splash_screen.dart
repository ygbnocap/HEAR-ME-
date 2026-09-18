// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'disclaimer_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;

  late Animation<double> _creatorFade;
  late Animation<double> _gameFade;
  late Animation<double> _bothFadeOut;

  @override
  void initState() {
    super.initState();

    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _creatorFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeInController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _gameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeInController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _bothFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeInController.forward();

        Timer(const Duration(milliseconds: 3500), () {
          if (mounted) _fadeOutController.forward();
        });

        Timer(const Duration(milliseconds: 5000), () {
          if (mounted) _navigateToDisclaimer();
        });
      }
    });
  }

  void _navigateToDisclaimer() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const DisclaimerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeInController, _fadeOutController]),
        builder: (context, child) {
          final double combinedOpacity = _bothFadeOut.value;

          return Opacity(
            opacity: combinedOpacity,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Логотип создателя
                  Opacity(
                    opacity: _creatorFade.value,
                    child: _LogoPlaceholder(
                      label: 'ЛОГОТИП',
                      icon: Icons.person_outline,
                      gradient: const [
                        AppColors.muted,
                        AppColors.primary,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(context, 0.05)),
                    child: Opacity(
                      opacity: (_creatorFade.value + _gameFade.value) / 2,
                      child: Container(
                        width: 2,
                        height: Responsive.getHeight(context, 0.1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Логотип игры
                  Opacity(
                    opacity: _gameFade.value,
                    child: _LogoPlaceholder(
                      label: 'КАК СЛЫШНО?',
                      icon: Icons.headphones,
                      gradient: const [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                      isAccent: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final bool isAccent;

  const _LogoPlaceholder({
    required this.label,
    required this.icon,
    required this.gradient,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.getWidth(context, 0.12),
          height: Responsive.getWidth(context, 0.12),
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 120, minHeight: 80, maxHeight: 120),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAccent
                  ? gradient
                  : [
                gradient[0].withOpacity(0.1),
                gradient[1].withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isAccent
                  ? gradient[0].withOpacity(0.6)
                  : AppColors.muted.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: isAccent
                ? [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ]
                : null,
          ),
          child: Icon(
            icon,
            size: Responsive.getFontSize(context, 48),
            color: isAccent ? Colors.white : AppColors.muted.withOpacity(0.6),
          ),
        ),
        SizedBox(height: Responsive.getHeight(context, 0.02)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 13),
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: isAccent ? Colors.white : AppColors.muted.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}