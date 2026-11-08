// lib/screens/final_game_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/gameplay_components.dart';
import 'start_screen.dart';

class FinalGameScreen extends StatefulWidget {
  final int accumulatedTime;
  final List<Question> remainingEasyQuestions;
  final List<Question> remainingMediumQuestions;
  final List<Question> remainingHardQuestions;
  const FinalGameScreen(
      {super.key,
      required this.accumulatedTime,
      required this.remainingEasyQuestions,
      required this.remainingMediumQuestions,
      required this.remainingHardQuestions});
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
  Timer? _timer;
  Timer? _countdownTimer;
  bool _terminal = false;
  bool _exiting = false;
  bool _showAnswer = false;
  int _totalRemainingTime = 0;

  @override
  void initState() {
    super.initState();
    _easyQuestions = List.from(widget.remainingEasyQuestions);
    _mediumQuestions = List.from(widget.remainingMediumQuestions);
    _hardQuestions = List.from(widget.remainingHardQuestions);
    _totalRemainingTime = widget.accumulatedTime;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startCategorySelection();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCategorySelection() {
    if (_terminal) return;
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
    if (_terminal || _showCountdown || _showQuestion) return;
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
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _totalRemainingTime--;
        if (_totalRemainingTime <= 0) {
          timer.cancel();
          _showTimeOutDialog();
        }
      });
    });
  }

  void _onAnswerPressed() {
    if (_terminal || !_showQuestion || _showAnswer) return;
    _timer?.cancel();
    setState(() {
      _showAnswer = true;
    });
  }

  void _onNextPressed() {
    if (_terminal || !_showAnswer || _currentQuestion == null) return;
    setState(() {
      _questionsPlayed++;
      _showAnswer = false;
      _showQuestion = false;
      _currentQuestion = null;
    });
    _startCategorySelection();
  }

  void _showTimeOutDialog() => _showTerminalDialog(
        title: 'ВРЕМЯ ВЫШЛО!',
        message: 'Накопленное время закончилось.\n\n'
            'Успели ответить на $_questionsPlayed вопросов из $_maxQuestions.\n\n'
            'Спасибо за игру!',
        timedOut: true,
      );

  void _goToMainMenu() => _showTerminalDialog(
        title: 'ИГРА ЗАВЕРШЕНА!',
        message: 'Финальный раунд окончен!\n\n'
            'Завершено вопросов: $_questionsPlayed из $_maxQuestions.\n\n'
            'Спасибо за игру!',
      );

  void _showTerminalDialog(
      {required String title, required String message, bool timedOut = false}) {
    if (!mounted || _terminal) return;
    _terminal = true;
    _countdownTimer?.cancel();
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Theme(
        data: GameplayTheme.data(context),
        child: PopScope(
          canPop: false,
          child: AlertDialog(
            scrollable: true,
            backgroundColor: GameplayTheme.raised,
            title: Text(title,
                style: TextStyle(
                    color:
                        timedOut ? GameplayTheme.error : GameplayTheme.primary,
                    fontSize: 24)),
            content: Text(message,
                style: const TextStyle(
                    color: GameplayTheme.text, fontSize: 16, height: 1.4)),
            actions: [
              FilledButton(
                onPressed: () {
                  if (_exiting) return;
                  _exiting = true;
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const StartScreen()),
                    (route) => false,
                  );
                },
                child: const Text('В ГЛАВНОЕ МЕНЮ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyQuestions = _easyQuestions.isNotEmpty ||
        _mediumQuestions.isNotEmpty ||
        _hardQuestions.isNotEmpty;
    if (!hasAnyQuestions && _questionsPlayed == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToMainMenu();
      });
      return const SizedBox.shrink();
    }
    return GameplayPage(
      hud: GameplayHud(items: [
        GameplayStatus(
            label: 'ФИНАЛЬНЫЙ РАУНД',
            value:
                '${(_questionsPlayed + 1).clamp(1, _maxQuestions)}/$_maxQuestions'),
        GameplayStatus(
            label: 'Осталось времени',
            value: gameplayTime(_totalRemainingTime),
            urgent: _totalRemainingTime <= 30),
      ]),
      child: _showCountdown
          ? GameplayCountdown(value: _countdownValue)
          : _showQuestion
              ? GameplayQuestion(
                  text: _showAnswer
                      ? 'ОТВЕТ: ${_currentQuestion?.answer ?? "Нет подсказки, придумайте сами!"}'
                      : _currentQuestion?.text ?? '',
                  showAnswer: _showAnswer,
                  actions: [
                    FilledButton(
                      onPressed:
                          _showAnswer ? _onNextPressed : _onAnswerPressed,
                      child: Text(_showAnswer ? 'ДАЛЕЕ' : 'ОТВЕТ'),
                    ),
                  ],
                )
              : GameplayCategorySelection(
                  title: 'ВЫБЕРИТЕ ВОПРОС',
                  subtitle:
                      'Осталось сыграть ${_maxQuestions - _questionsPlayed} вопросов',
                  counts: [
                    _easyQuestions.length,
                    _mediumQuestions.length,
                    _hardQuestions.length
                  ],
                  onSelected: _selectCategory,
                ),
    );
  }
}
