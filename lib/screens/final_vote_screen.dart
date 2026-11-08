import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
import 'final_game_screen.dart';
import 'start_screen.dart';

class FinalVoteScreen extends StatefulWidget {
  final int accumulatedTime;
  final int correctAnswers;
  final int totalQuestions;
  final List<Question> remainingEasyQuestions;
  final List<Question> remainingMediumQuestions;
  final List<Question> remainingHardQuestions;
  const FinalVoteScreen(
      {super.key,
      required this.accumulatedTime,
      required this.correctAnswers,
      required this.totalQuestions,
      required this.remainingEasyQuestions,
      required this.remainingMediumQuestions,
      required this.remainingHardQuestions});
  @override
  State<FinalVoteScreen> createState() => _FinalVoteScreenState();
}

class _FinalVoteScreenState extends State<FinalVoteScreen> {
  @override
  Widget build(BuildContext context) {
    final hasRemainingQuestions = widget.remainingEasyQuestions.isNotEmpty ||
        widget.remainingMediumQuestions.isNotEmpty ||
        widget.remainingHardQuestions.isNotEmpty;
    return StudioPage(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StudioHeader(
          title: hasRemainingQuestions
              ? 'ИТОГИ ОСНОВНОЙ ИГРЫ'
              : 'ИГРА ЗАВЕРШЕНА!'),
      LayoutBuilder(builder: (context, constraints) {
        final summary = StudioSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ВАША СТАТИСТИКА',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GameplayTheme.text)),
          const SizedBox(height: 12),
          Text(
              'Правильных ответов: ${widget.correctAnswers} из ${widget.totalQuestions}',
              style: const TextStyle(
                  fontSize: 16, height: 1.5, color: GameplayTheme.text)),
          const SizedBox(height: 8),
          Text('Накоплено времени: ${_formatTime(widget.accumulatedTime)}',
              style: const TextStyle(
                  fontSize: 16, height: 1.5, color: GameplayTheme.secondary)),
          if (hasRemainingQuestions) ...[
            const SizedBox(height: 8),
            Text(
                'ТОЧНОСТЬ: ${widget.totalQuestions > 0 ? (widget.correctAnswers / widget.totalQuestions * 100).toStringAsFixed(0) : 0}%',
                style: const TextStyle(
                    fontSize: 16, height: 1.5, color: GameplayTheme.secondary)),
          ],
        ]));
        final next =
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (hasRemainingQuestions) ...[
            const StudioSurface(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('ПРОГОЛОСУЙТЕ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: GameplayTheme.primary)),
                  SizedBox(height: 8),
                  Text('за самого активного и самого неактивного игрока',
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: GameplayTheme.text)),
                ])),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => FinalGameScreen(
                              accumulatedTime: widget.accumulatedTime,
                              remainingEasyQuestions:
                                  widget.remainingEasyQuestions,
                              remainingMediumQuestions:
                                  widget.remainingMediumQuestions,
                              remainingHardQuestions:
                                  widget.remainingHardQuestions,
                            ))),
                child: const Text('К ФИНАЛЬНОМУ РАУНДУ',
                    textAlign: TextAlign.center)),
          ] else
            FilledButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const StartScreen()),
                    (route) => false),
                child:
                    const Text('В ГЛАВНОЕ МЕНЮ', textAlign: TextAlign.center)),
        ]);
        if (constraints.maxWidth >= 680 &&
            MediaQuery.textScalerOf(context).scale(16) <= 22) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: summary),
            const SizedBox(width: 16),
            Expanded(child: next)
          ]);
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [summary, const SizedBox(height: 16), next]);
      }),
    ]));
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$seconds' 'с';
  }
}
