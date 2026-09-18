// lib/screens/game_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../services/pack_manager.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'final_vote_screen.dart';
import 'start_screen.dart';

class GameScreen extends StatefulWidget {
  final int timeSeconds;

  const GameScreen({super.key, required this.timeSeconds});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Question> _easyQuestions;
  late List<Question> _mediumQuestions;
  late List<Question> _hardQuestions;

  int _roundsPlayed = 0;
  static const int _maxRounds = 7;

  bool _showCountdown = false;
  int _countdownValue = 3;

  bool _showQuestion = false;
  Question? _currentQuestion;
  Difficulty? _currentDifficulty;
  int _timeLeft = 0;
  Timer? _timer;
  bool _showAnswer = false;

  // Для подсчёта очков
  int _correctAnswers = 0;
  int _accumulatedTime = 0;

  @override
  void initState() {
    super.initState();
    final pack = PackManager().selectedPack!;
    _easyQuestions = List.from(pack.easyQuestions);
    _mediumQuestions = List.from(pack.mediumQuestions);
    _hardQuestions = List.from(pack.hardQuestions);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCategorySelection() {
    if (_roundsPlayed >= _maxRounds) {
      _goToFinalVote();
      return;
    }
    setState(() {
      _showCountdown = false;
      _showQuestion = false;
      _showAnswer = false;
      _currentQuestion = null;
      _currentDifficulty = null;
    });
  }

  void _selectCategory(Difficulty difficulty) {
    Question question;
    switch (difficulty) {
      case Difficulty.easy:
        if (_easyQuestions.isEmpty) return;
        question = _easyQuestions.removeAt(0);
        break;
      case Difficulty.medium:
        if (_mediumQuestions.isEmpty) return;
        question = _mediumQuestions.removeAt(0);
        break;
      case Difficulty.hard:
        if (_hardQuestions.isEmpty) return;
        question = _hardQuestions.removeAt(0);
        break;
    }

    setState(() {
      _currentQuestion = question;
      _currentDifficulty = difficulty;
      _showCountdown = true;
      _countdownValue = 3;
    });

    _runCountdown();
  }

  void _runCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdownValue--;
      });
      if (_countdownValue <= 0) {
        timer.cancel();
        setState(() {
          _showCountdown = false;
          _showQuestion = true;
          _timeLeft = widget.timeSeconds;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        // Таймер закончился, но ответ показываем только по кнопке
        // Игрок должен сам нажать "ОТВЕТ"
      }
    });
  }

  void _onAnswerPressed() {
    if (_timer != null) {
      _timer?.cancel();
    }
    setState(() {
      _showAnswer = true;
    });
  }

  void _onCorrectPressed() {
    int addedTime = 0;
    switch (_currentDifficulty) {
      case Difficulty.easy:
        addedTime = 30;
        break;
      case Difficulty.medium:
        addedTime = 60;
        break;
      case Difficulty.hard:
        addedTime = 90;
        break;
      default:
        addedTime = 0;
    }

    setState(() {
      _correctAnswers++;
      _accumulatedTime += addedTime;
      _roundsPlayed++;
      _showAnswer = false;
      _showQuestion = false;
      _currentQuestion = null;
    });
    _startCategorySelection();
  }

  void _onWrongPressed() {
    setState(() {
      _roundsPlayed++;
      _showAnswer = false;
      _showQuestion = false;
      _currentQuestion = null;
    });
    _startCategorySelection();
  }

  void _goToFinalVote() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FinalVoteScreen(
          accumulatedTime: _accumulatedTime,
          correctAnswers: _correctAnswers,
          totalQuestions: _roundsPlayed,
          remainingEasyQuestions: _easyQuestions,
          remainingMediumQuestions: _mediumQuestions,
          remainingHardQuestions: _hardQuestions,
        ),
      ),
    );
  }

  void _goToMainMenu() {
    _timer?.cancel();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const StartScreen()),
          (route) => false,
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return '0:$s';
  }

  String _formatAccumulatedTime() {
    final minutes = _accumulatedTime ~/ 60;
    final seconds = _accumulatedTime % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${_accumulatedTime}с';
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Верхняя панель статистики
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(context, 0.03),
                  vertical: Responsive.getHeight(context, 0.008),
                ),
                margin: EdgeInsets.all(Responsive.getWidth(context, 0.02)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(Icons.check_circle, '$_correctAnswers', AppColors.accent, context),
                    _statItem(Icons.timer, _formatAccumulatedTime(), AppColors.primary, context),
                    _statItem(Icons.straighten, '$_roundsPlayed/$_maxRounds', AppColors.secondary, context),
                  ],
                ),
              ),
              // Основной контент
              Expanded(
                child: _showCountdown
                    ? _buildCountdown()
                    : _showQuestion
                    ? _buildQuestionCard()
                    : _buildCategorySelection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String text, Color color, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: Responsive.getFontSize(context, 18), color: color),
        SizedBox(width: Responsive.getWidth(context, 0.01)),
        Text(
          text,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    return Center(
      child: AnimatedScale(
        scale: _countdownValue == 0 ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Text(
          _countdownValue > 0 ? '$_countdownValue' : 'ВОПРОС!',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 100),
            fontWeight: FontWeight.bold,
            color: _countdownValue > 0 ? AppColors.primary : AppColors.highlight,
            letterSpacing: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    int pointsValue = 0;
    Color pointsColor = AppColors.accent;

    switch (_currentDifficulty) {
      case Difficulty.easy:
        pointsValue = 30;
        pointsColor = AppColors.accent;
        break;
      case Difficulty.medium:
        pointsValue = 60;
        pointsColor = AppColors.secondary;
        break;
      case Difficulty.hard:
        pointsValue = 90;
        pointsColor = AppColors.highlight;
        break;
      default:
        pointsValue = 0;
    }

    return Center(
      child: Container(
        width: Responsive.getWidth(context, 0.9),
        constraints: BoxConstraints(
          minWidth: 320,
          maxWidth: 800,
          minHeight: 350,
          maxHeight: 600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Responsive.getWidth(context, 0.05)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(context, 0.04),
                      vertical: Responsive.getHeight(context, 0.01),
                    ),
                    decoration: BoxDecoration(
                      color: pointsColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: pointsColor.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      '+${_formatTime(pointsValue)}',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: pointsColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(context, 0.04),
                      vertical: Responsive.getHeight(context, 0.01),
                    ),
                    decoration: BoxDecoration(
                      color: _timeLeft <= 10 ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _timeLeft <= 10 ? Colors.red.withOpacity(0.4) : AppColors.primary.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _formatTime(_timeLeft),
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 10 ? Colors.red : AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.getHeight(context, 0.04)),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      _showAnswer
                          ? 'ОТВЕТ: ${_currentQuestion?.answer ?? "Нет подсказки, придумайте сами!"}'
                          : _currentQuestion?.text ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 26),
                        fontWeight: FontWeight.w600,
                        color: _showAnswer ? AppColors.highlight : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Responsive.getHeight(context, 0.04)),
              if (!_showAnswer)
                _buildButton('ОТВЕТ', [AppColors.primary, AppColors.secondary], _onAnswerPressed, context)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildResultButton('ПРАВИЛЬНО', AppColors.accent, _onCorrectPressed, context),
                    ),
                    SizedBox(width: Responsive.getWidth(context, 0.02)),
                    Expanded(
                      child: _buildResultButton('НЕПРАВИЛЬНО', AppColors.highlight, _onWrongPressed, context),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, List<Color> gradient, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getWidth(context, 0.1),
          vertical: Responsive.getHeight(context, 0.02),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResultButton(String text, Color color, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.getHeight(context, 0.018),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 18),
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(context, 0.05),
        vertical: Responsive.getHeight(context, 0.02),
      ),
      child: Column(
        children: [
          // Кнопка выхода
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: _goToMainMenu,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(context, 0.03),
                  vertical: Responsive.getHeight(context, 0.008),
                ),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.muted.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app, size: Responsive.getFontSize(context, 16), color: AppColors.muted),
                    SizedBox(width: Responsive.getWidth(context, 0.01)),
                    Text(
                      'ВЫЙТИ',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.02)),
          // Заголовок
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.muted, AppColors.highlight],
            ).createShader(bounds),
            child: Text(
              'РАУНД ${_roundsPlayed + 1} / $_maxRounds',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 28),
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.005)),
          Text(
            'ВЫБЕРИТЕ КАТЕГОРИЮ',
            style: TextStyle(
              color: AppColors.muted.withOpacity(0.6),
              fontSize: Responsive.getFontSize(context, 12),
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.03)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoryCardVertical(
                  title: 'ЛЁГКИЕ',
                  difficulty: Difficulty.easy,
                  color: AppColors.accent,
                  count: _easyQuestions.length,
                  pointsText: '+30',
                  context: context,
                ),
                _categoryCardVertical(
                  title: 'СРЕДНИЕ',
                  difficulty: Difficulty.medium,
                  color: AppColors.secondary,
                  count: _mediumQuestions.length,
                  pointsText: '+60',
                  context: context,
                ),
                _categoryCardVertical(
                  title: 'СЛОЖНЫЕ',
                  difficulty: Difficulty.hard,
                  color: AppColors.highlight,
                  count: _hardQuestions.length,
                  pointsText: '+90',
                  context: context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCardVertical({
    required String title,
    required Difficulty difficulty,
    required Color color,
    required int count,
    required String pointsText,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: count > 0 ? () => _selectCategory(difficulty) : null,
      child: Opacity(
        opacity: count > 0 ? 1.0 : 0.4,
        child: Container(
          width: double.infinity,
          height: Responsive.getHeight(context, 0.09),
          margin: EdgeInsets.symmetric(horizontal: Responsive.getWidth(context, 0.15)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withOpacity(0.25),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: Responsive.getWidth(context, 0.1),
                height: Responsive.getWidth(context, 0.1),
                constraints: const BoxConstraints(minWidth: 45, maxWidth: 55),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: color,
                ),
              ),
              Text(
                pointsText,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}