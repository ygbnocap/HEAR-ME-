// lib/screens/final_vote_screen.dart
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'final_game_screen.dart';
import 'start_screen.dart';

class FinalVoteScreen extends StatefulWidget {
  final int accumulatedTime;
  final int correctAnswers;
  final int totalQuestions;
  final List<Question> remainingEasyQuestions;
  final List<Question> remainingMediumQuestions;
  final List<Question> remainingHardQuestions;

  const FinalVoteScreen({
    super.key,
    required this.accumulatedTime,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.remainingEasyQuestions,
    required this.remainingMediumQuestions,
    required this.remainingHardQuestions,
  });

  @override
  State<FinalVoteScreen> createState() => _FinalVoteScreenState();
}

class _FinalVoteScreenState extends State<FinalVoteScreen> {
  @override
  Widget build(BuildContext context) {
    final hasRemainingQuestions =
        widget.remainingEasyQuestions.isNotEmpty ||
            widget.remainingMediumQuestions.isNotEmpty ||
            widget.remainingHardQuestions.isNotEmpty;

    // Если нет оставшихся вопросов - показываем финальную статистику
    if (!hasRemainingQuestions) {
      return _buildFinalStatsOnly();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.getPadding(context).horizontal),
            child: Column(
              children: [
                SizedBox(height: Responsive.getHeight(context, 0.03)),
                // Заголовок
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.highlight],
                  ).createShader(bounds),
                  child: Text(
                    'ИТОГИ ОСНОВНОЙ ИГРЫ',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 28),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.02)),
                Container(
                  width: Responsive.getWidth(context, 0.15),
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.highlight],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.04)),

                // Статистика
                Container(
                  padding: EdgeInsets.all(Responsive.getWidth(context, 0.04)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ВАША СТАТИСТИКА',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 16),
                          letterSpacing: 3,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 0.02)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _statChip('ПРАВИЛЬНО', '${widget.correctAnswers}', AppColors.accent),
                          SizedBox(width: Responsive.getWidth(context, 0.02)),
                          _statChip('ВСЕГО', '${widget.totalQuestions}', AppColors.secondary),
                          SizedBox(width: Responsive.getWidth(context, 0.02)),
                          _statChip('НАКОПЛЕНО', _formatTime(widget.accumulatedTime), AppColors.highlight),
                        ],
                      ),
                      SizedBox(height: Responsive.getHeight(context, 0.02)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(context, 0.04),
                          vertical: Responsive.getHeight(context, 0.01),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ТОЧНОСТЬ: ${widget.totalQuestions > 0 ? (widget.correctAnswers / widget.totalQuestions * 100).toStringAsFixed(0) : 0}%',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.getHeight(context, 0.04)),

                // Текст для голосования
                Container(
                  padding: EdgeInsets.all(Responsive.getWidth(context, 0.04)),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.how_to_vote_outlined,
                        size: Responsive.getFontSize(context, 32),
                        color: AppColors.accent,
                      ),
                      SizedBox(height: Responsive.getHeight(context, 0.01)),
                      Text(
                        'ПРОГОЛОСУЙТЕ',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(context, 0.005)),
                      Text(
                        'за самого активного и самого неактивного игрока',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 12),
                          color: AppColors.muted,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.getHeight(context, 0.04)),

                // Кнопка начала финального раунда
                _buildStartButton(),

                SizedBox(height: Responsive.getHeight(context, 0.03)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalStatsOnly() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(Responsive.getWidth(context, 0.06)),
              margin: EdgeInsets.all(Responsive.getWidth(context, 0.05)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: Responsive.getFontSize(context, 64),
                    color: AppColors.accent,
                  ),
                  SizedBox(height: Responsive.getHeight(context, 0.02)),
                  Text(
                    'ИГРА ЗАВЕРШЕНА!',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 28),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(context, 0.02)),
                  Text(
                    'Правильных ответов: ${widget.correctAnswers} из ${widget.totalQuestions}',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 16),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(context, 0.01)),
                  Text(
                    'Накоплено времени: ${_formatTime(widget.accumulatedTime)}',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 16),
                      color: AppColors.muted,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(context, 0.03)),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const StartScreen()),
                            (route) => false,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(context, 0.08),
                        vertical: Responsive.getHeight(context, 0.015),
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'В ГЛАВНОЕ МЕНЮ',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(context, 0.03),
        vertical: Responsive.getHeight(context, 0.01),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 10),
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}с';
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FinalGameScreen(
              accumulatedTime: widget.accumulatedTime, // Передаём накопленное время
              remainingEasyQuestions: widget.remainingEasyQuestions,
              remainingMediumQuestions: widget.remainingMediumQuestions,
              remainingHardQuestions: widget.remainingHardQuestions,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.getHeight(context, 0.015),
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
        child: Center(
          child: Text(
            'К ФИНАЛЬНОМУ РАУНДУ',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}