// lib/screens/final_game_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'start_screen.dart';

class FinalGameScreen extends StatefulWidget {
  final int accumulatedTime;
  final List<Question> remainingEasyQuestions;
  final List<Question> remainingMediumQuestions;
  final List<Question> remainingHardQuestions;

  const FinalGameScreen({
    super.key,
    required this.accumulatedTime,
    required this.remainingEasyQuestions,
    required this.remainingMediumQuestions,
    required this.remainingHardQuestions,
  });

  @override
  State<FinalGameScreen> createState() => _FinalGameScreenState();
}

class _FinalGameScreenState extends State<FinalGameScreen> {
  late List<Question> _easyQuestions;
  late List<Question> _mediumQuestions;
  late List<Question> _hardQuestions;

  int _questionsPlayed = 0;
  static const int _maxQuestions = 3;

  bool _showCountdown = false;
  int _countdownValue = 3;

  bool _showQuestion = false;
  Question? _currentQuestion;
  int _timeLeft = 0;
  Timer? _timer;
  bool _showAnswer = false;

  // Общее накопленное время
  int _totalRemainingTime = 0;

  @override
  void initState() {
    super.initState();
    _easyQuestions = List.from(widget.remainingEasyQuestions);
    _mediumQuestions = List.from(widget.remainingMediumQuestions);
    _hardQuestions = List.from(widget.remainingHardQuestions);

    _totalRemainingTime = widget.accumulatedTime;

    _startCategorySelection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCategorySelection() {
    if (_questionsPlayed >= _maxQuestions) {
      _goToMainMenu();
      return;
    }
    if (_totalRemainingTime <= 0) {
      _showTimeOutDialog();
      return;
    }
    setState(() {
      _showCountdown = false;
      _showQuestion = false;
      _showAnswer = false;
      _currentQuestion = null;
    });
  }

  void _selectCategory(Difficulty difficulty) {
    Question question;

    switch (difficulty) {
      case Difficulty.easy:
        if (_easyQuestions.isEmpty && _questionsPlayed < _maxQuestions) {
          if (_mediumQuestions.isNotEmpty) {
            _selectCategory(Difficulty.medium);
          } else if (_hardQuestions.isNotEmpty) {
            _selectCategory(Difficulty.hard);
          }
          return;
        }
        if (_easyQuestions.isEmpty) return;
        question = _easyQuestions.removeAt(0);
        break;
      case Difficulty.medium:
        if (_mediumQuestions.isEmpty && _questionsPlayed < _maxQuestions) {
          if (_easyQuestions.isNotEmpty) {
            _selectCategory(Difficulty.easy);
          } else if (_hardQuestions.isNotEmpty) {
            _selectCategory(Difficulty.hard);
          }
          return;
        }
        if (_mediumQuestions.isEmpty) return;
        question = _mediumQuestions.removeAt(0);
        break;
      case Difficulty.hard:
        if (_hardQuestions.isEmpty && _questionsPlayed < _maxQuestions) {
          if (_easyQuestions.isNotEmpty) {
            _selectCategory(Difficulty.easy);
          } else if (_mediumQuestions.isNotEmpty) {
            _selectCategory(Difficulty.medium);
          }
          return;
        }
        if (_hardQuestions.isEmpty) return;
        question = _hardQuestions.removeAt(0);
        break;
    }

    setState(() {
      _currentQuestion = question;
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
          _timeLeft = _totalRemainingTime;
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
        _totalRemainingTime--;
        _timeLeft = _totalRemainingTime;

        if (_totalRemainingTime <= 0) {
          timer.cancel();
          _showTimeOutDialog();
        }
      });
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

  void _onNextPressed() {
    setState(() {
      _questionsPlayed++;
      _showAnswer = false;
      _showQuestion = false;
      _currentQuestion = null;
    });
    _startCategorySelection();
  }

  void _showTimeOutDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        title: Text(
          'ВРЕМЯ ВЫШЛО!',
          style: TextStyle(
            color: AppColors.highlight,
            fontSize: Responsive.getFontSize(context, 24),
          ),
        ),
        content: Text(
          'Накопленное время закончилось.\n\n'
              'Успели ответить на $_questionsPlayed вопросов из $_maxQuestions.\n\n'
              'Спасибо за игру!',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const StartScreen()),
                    (route) => false,
              );
            },
            child: Text(
              'В ГЛАВНОЕ МЕНЮ',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _goToMainMenu() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        title: Text(
          'ИГРА ЗАВЕРШЕНА!',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: Responsive.getFontSize(context, 24),
          ),
        ),
        content: Text(
          'Финальный раунд окончен!\n\n'
              'Вы успешно ответили на все $_maxQuestions вопросов!\n\n'
              'Спасибо за игру!',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getFontSize(context, 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const StartScreen()),
                    (route) => false,
              );
            },
            child: Text(
              'В ГЛАВНОЕ МЕНЮ',
              style: TextStyle(color: AppColors.primary),
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
    return '$remainingSeconds с.';
  }

  @override
  Widget build(BuildContext context) {
    // Проверяем, есть ли доступные вопросы
    final hasAnyQuestions = _easyQuestions.isNotEmpty ||
        _mediumQuestions.isNotEmpty ||
        _hardQuestions.isNotEmpty;

    if (!hasAnyQuestions && _questionsPlayed == 0) {
      // Если нет ни одного вопроса - сразу возвращаемся
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToMainMenu();
      });
      return const SizedBox.shrink();
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
          child: Column(
            children: [
              // Верхняя панель с прогрессом и накопленным временем
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
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: Responsive.getFontSize(context, 20),
                          color: _totalRemainingTime <= 30 ? Colors.red : AppColors.primary,
                        ),
                        SizedBox(width: Responsive.getWidth(context, 0.01)),
                        Text(
                          _formatTime(_totalRemainingTime),
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: _totalRemainingTime <= 30 ? Colors.red : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: Responsive.getHeight(context, 0.03),
                      color: AppColors.muted.withOpacity(0.3),
                    ),
                    Row(
                      children: [
                        Text(
                          'ФИНАЛЬНЫЙ РАУНД',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 14),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(width: Responsive.getWidth(context, 0.02)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(context, 0.02),
                            vertical: Responsive.getHeight(context, 0.003),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_questionsPlayed + 1}/$_maxQuestions',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(context, 14),
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildCountdown() {
    return Center(
      child: AnimatedScale(
        scale: _countdownValue == 0 ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Text(
          _countdownValue > 0 ? '$_countdownValue' : 'ВОПРОС ${_questionsPlayed + 1}!',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 80),
            fontWeight: FontWeight.bold,
            color: _countdownValue > 0 ? AppColors.primary : AppColors.highlight,
            letterSpacing: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Center(
      child: Container(
        width: Responsive.getWidth(context, 0.9),
        constraints: BoxConstraints(
          minWidth: 320,
          maxWidth: 800,
          minHeight: 350,
          maxHeight: 550,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Responsive.getWidth(context, 0.05)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(context, 0.04),
                  vertical: Responsive.getHeight(context, 0.01),
                ),
                decoration: BoxDecoration(
                  color: _totalRemainingTime <= 30
                      ? Colors.red.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _totalRemainingTime <= 30
                        ? Colors.red.withOpacity(0.5)
                        : AppColors.primary.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Text(
                  _formatTime(_totalRemainingTime),
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 32),
                    fontWeight: FontWeight.bold,
                    color: _totalRemainingTime <= 30 ? Colors.red : AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
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
                _buildButton('ДАЛЕЕ', [AppColors.accent, AppColors.primary], _onNextPressed, context),
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
          vertical: Responsive.getHeight(context, 0.018),
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

  Widget _buildCategorySelection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(context, 0.05),
        vertical: Responsive.getHeight(context, 0.02),
      ),
      child: Column(
        children: [
          // Заголовок
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.muted, AppColors.highlight],
            ).createShader(bounds),
            child: Text(
              'ВЫБЕРИТЕ ВОПРОС',
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
            'Осталось сыграть ${_maxQuestions - _questionsPlayed} вопросов',
            style: TextStyle(
              color: AppColors.muted.withOpacity(0.6),
              fontSize: Responsive.getFontSize(context, 12),
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: Responsive.getHeight(context, 0.03)),
          // Три блока вертикально
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoryCardVertical(
                  title: 'ЛЁГКИЕ',
                  difficulty: Difficulty.easy,
                  color: AppColors.accent,
                  count: _easyQuestions.length,
                  isEnabled: _easyQuestions.isNotEmpty,
                  context: context,
                ),
                _categoryCardVertical(
                  title: 'СРЕДНИЕ',
                  difficulty: Difficulty.medium,
                  color: AppColors.secondary,
                  count: _mediumQuestions.length,
                  isEnabled: _mediumQuestions.isNotEmpty,
                  context: context,
                ),
                _categoryCardVertical(
                  title: 'СЛОЖНЫЕ',
                  difficulty: Difficulty.hard,
                  color: AppColors.highlight,
                  count: _hardQuestions.length,
                  isEnabled: _hardQuestions.isNotEmpty,
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
    required bool isEnabled,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: isEnabled ? () => _selectCategory(difficulty) : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              SizedBox(width: Responsive.getWidth(context, 0.03)),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}