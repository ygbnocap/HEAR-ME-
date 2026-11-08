// lib/screens/game_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../services/pack_manager.dart';
import '../widgets/gameplay_components.dart';
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
  Timer? _countdownTimer;
  bool _leaving = false;
  bool _showAnswer = false;
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
    _countdownTimer?.cancel();
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
    if (_leaving || _showCountdown || _showQuestion) return;
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
          _timeLeft = widget.timeSeconds;
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
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        // Ответ по-прежнему открывается только по кнопке.
      }
    });
  }

  void _onAnswerPressed() {
    if (_leaving || !_showQuestion || _showAnswer) return;
    _timer?.cancel();
    setState(() {
      _showAnswer = true;
    });
  }

  void _onCorrectPressed() {
    if (_leaving || !_showAnswer || _currentQuestion == null) return;
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
    if (_leaving || !_showAnswer || _currentQuestion == null) return;
    setState(() {
      _roundsPlayed++;
      _showAnswer = false;
      _showQuestion = false;
      _currentQuestion = null;
    });
    _startCategorySelection();
  }

  void _goToFinalVote() {
    if (_leaving) return;
    _leaving = true;
    _timer?.cancel();
    _countdownTimer?.cancel();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => FinalVoteScreen(
        accumulatedTime: _accumulatedTime,
        correctAnswers: _correctAnswers,
        totalQuestions: _roundsPlayed,
        remainingEasyQuestions: _easyQuestions,
        remainingMediumQuestions: _mediumQuestions,
        remainingHardQuestions: _hardQuestions,
      ),
    ));
  }

  void _goToMainMenu() {
    if (_leaving) return;
    _leaving = true;
    _countdownTimer?.cancel();
    _timer?.cancel();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const StartScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => GameplayPage(
        hud: GameplayHud(
          onExit: !_showCountdown && !_showQuestion ? _goToMainMenu : null,
          items: [
            GameplayStatus(label: 'Верно', value: '$_correctAnswers'),
            GameplayStatus(
                label: 'Запас времени', value: gameplayTime(_accumulatedTime)),
            GameplayStatus(
                label: 'Сыграно', value: '$_roundsPlayed/$_maxRounds'),
          ],
        ),
        child: _showCountdown
            ? GameplayCountdown(value: _countdownValue)
            : _showQuestion
                ? _buildQuestionCard()
                : GameplayCategorySelection(
                    title: 'РАУНД ${_roundsPlayed + 1} / $_maxRounds',
                    subtitle: 'ВЫБЕРИТЕ КАТЕГОРИЮ',
                    counts: [
                      _easyQuestions.length,
                      _mediumQuestions.length,
                      _hardQuestions.length
                    ],
                    onSelected: _selectCategory,
                    showBonus: true,
                  ),
      );

  Widget _buildQuestionCard() => GameplayQuestion(
        text: _showAnswer
            ? 'ОТВЕТ: ${_currentQuestion?.answer ?? "Нет подсказки, придумайте сами!"}'
            : _currentQuestion?.text ?? '',
        showAnswer: _showAnswer,
        status: Wrap(
          spacing: 24,
          runSpacing: 4,
          children: [
            GameplayStatus(
                label: 'Бонус',
                value: '+${((_currentDifficulty?.index ?? -1) + 1) * 30} с'),
            GameplayStatus(
                label: 'Время на ответ',
                value: gameplayTime(_timeLeft),
                urgent: _timeLeft <= 10),
          ],
        ),
        actions: !_showAnswer
            ? [
                FilledButton(
                    onPressed: _onAnswerPressed, child: const Text('ОТВЕТ'))
              ]
            : [
                FilledButton(
                    onPressed: _onCorrectPressed,
                    child: const Text('ПРАВИЛЬНО')),
                OutlinedButton(
                    onPressed: _onWrongPressed,
                    child: const Text('НЕПРАВИЛЬНО')),
              ],
      );
}
