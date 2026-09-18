// lib/screens/disclaimer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'start_screen.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _autoNavigateTimer;
  int _secondsLeft = 7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    _autoNavigateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });
      if (_secondsLeft <= 0) {
        timer.cancel();
        _navigateToStart();
      }
    });
  }

  void _navigateToStart() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StartScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(context, 0.1),
                  vertical: Responsive.getHeight(context, 0.05),
                ),
                child: Column(
                  children: [
                    SizedBox(height: Responsive.getHeight(context, 0.03)),
                    Text(
                      'ДИСКЛЕЙМЕР',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 0.01)),
                    Container(
                      width: Responsive.getWidth(context, 0.6),
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.highlight, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 0.05)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _disclaimerBlock(
                              text: 'Концепт игры "Как слышно?" вдохновлён и позаимствован с импровизационного шоу "Громкий вопрос" от ИМПРОКОМ.'
                                  ' Все права на оригинальный формат, название и концепцию принадлежат их законным владельцам.'
                                  ' Данное приложение является фанатским некоммерческим проектом, созданным исключительно в развлекательных целях.'
                                  ' Автор приложения не претендует на интеллектуальную собственность оригинального шоу и не имеет к нему прямого отношения.'
                                  ' Если вам понравился формат — поддержите оригинальное шоу "Громкий вопрос" и творческую команду ИМПРОКОМ.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 0.04)),
                    GestureDetector(
                      onTap: _navigateToStart,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(context, 0.1),
                          vertical: Responsive.getHeight(context, 0.025),
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          'ПРОДОЛЖИТЬ ($_secondsLeft)',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _disclaimerBlock({required String text}) {
    return Container(
      padding: EdgeInsets.all(Responsive.getWidth(context, 0.03)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: Responsive.getWidth(context, 0.02)),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: Responsive.getFontSize(context, 15),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}