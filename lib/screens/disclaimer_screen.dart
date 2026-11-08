import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
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
  bool _navigating = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _autoNavigateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _navigateToStart();
      }
    });
  }

  void _navigateToStart() {
    if (_navigating || !mounted) return;
    _navigating = true;
    _autoNavigateTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StartScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StudioPage(
      maxWidth: 720,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
                opacity: MediaQuery.disableAnimationsOf(context)
                    ? 1
                    : _fadeAnimation.value,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('ДИСКЛЕЙМЕР',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: GameplayTheme.text)),
                      const SizedBox(height: 20),
                      const Text(
                        'Концепт игры "Как слышно?" вдохновлён и позаимствован с импровизационного шоу "Громкий вопрос" от ИМПРОКОМ.'
                        ' Все права на оригинальный формат, название и концепцию принадлежат их законным владельцам.'
                        ' Данное приложение является фанатским некоммерческим проектом, созданным исключительно в развлекательных целях.'
                        ' Автор приложения не претендует на интеллектуальную собственность оригинального шоу и не имеет к нему прямого отношения.'
                        ' Если вам понравился формат — поддержите оригинальное шоу "Громкий вопрос" и творческую команду ИМПРОКОМ.',
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: GameplayTheme.secondary),
                      ),
                      const SizedBox(height: 20),
                      Align(
                          alignment: Alignment.center,
                          child: FilledButton(
                              onPressed: _navigateToStart,
                              child: Text('ПРОДОЛЖИТЬ ($_secondsLeft)'))),
                    ]),
              )));
}
