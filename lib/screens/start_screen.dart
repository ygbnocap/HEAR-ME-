// lib/screens/start_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'time_select_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(context, 0.1),
                  vertical: Responsive.getHeight(context, 0.04),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D1B4E), Color(0xFF1A1025)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ).createShader(bounds),
                      child: Text(
                        'КАК',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 52),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(context, 0.005)),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.highlight, AppColors.accent],
                      ).createShader(bounds),
                      child: Text(
                        'СЛЫШНО?',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 52),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.getHeight(context, 0.1)),
              _AnimatedStartButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TimeSelectScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: Responsive.getHeight(context, 0.03)),
              _RulesButton(
                onTap: () => _showRulesCarousel(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRulesCarousel(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RulesCarouselDialog(),
    );
  }
}

class RulesCarouselDialog extends StatefulWidget {
  const RulesCarouselDialog({super.key});

  @override
  State<RulesCarouselDialog> createState() => _RulesCarouselDialogState();
}

class _RulesCarouselDialogState extends State<RulesCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _rules = const [
    {
      'number': '1',
      'title': 'Командная игра',
      'text': '"Как слышно?" — командная игра. Побеждают или проигрывают все вместе. Результат общий, ответственность общая.',
      'icon': Icons.groups_outlined,
    },
    {
      'number': '2',
      'title': 'Наушники обязательны',
      'text': 'Каждый участник надевает наушники с громкой музыкой до старта вопроса и снимает их только после окончания ответа.',
      'icon': Icons.headphones_outlined,
    },
    {
      'number': '3',
      'title': 'Поле карточек',
      'text': 'На столе 12 карточек: 4 лёгких, 4 средних и 4 сложных вопроса. Игроки по очереди выбирают любую открытую карточку.',
      'icon': Icons.grid_view_outlined,
    },
    {
      'number': '4',
      'title': 'Условие балла',
      'text': 'Балл засчитывается только если все участники дали одинаковый и при этом правильный ответ. Согласованность важнее скорости.',
      'icon': Icons.check_circle_outline,
    },
    {
      'number': '5',
      'title': 'Время на ответ',
      'text': 'На объяснение вопроса участникам даётся выбранное время: 1:00, 1:30 или 2:00. Следи за таймером!',
      'icon': Icons.timer_outlined,
    },
    {
      'number': '6',
      'title': 'Система очков',
      'text': 'За правильный ответ начисляются время, которое будет использовано в финальной игре: лёгкий вопрос — 0:30, средний — 1:00, сложный — 1:30.',
      'icon': Icons.stars_outlined,
    },
    {
      'number': '7',
      'title': '7 раундов',
      'text': 'Основная игра длится ровно 7 раундов. Необязательно открывать все карточки — стратегия выбора имеет значение.',
      'icon': Icons.format_list_numbered,
    },
    {
      'number': '8',
      'title': 'Финальный раунд',
      'text': 'После основной части все игроки тайно голосуют: кто лучше всего проявил себя, и кто — хуже всего. Два выбранных игрока разыгрывают оставшиеся 3 из 5 вопросов в дуэли.',
      'icon': Icons.how_to_vote_outlined,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _rules.length) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(context, 0.05),
        vertical: Responsive.getHeight(context, 0.02),
      ),
      child: Container(
        width: Responsive.getWidth(context, 0.8),
        height: Responsive.getHeight(context, 0.85),
        constraints: BoxConstraints(
          minWidth: 300,
          maxWidth: 600,
          minHeight: 500,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1025), Color(0xFF2D1B4E)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.secondary, AppColors.highlight],
                      ).createShader(bounds),
                      child: Text(
                        'ПРАВИЛА ИГРЫ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(context, 26),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.muted.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.muted.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${_currentPage + 1} / ${_rules.length}',
              style: TextStyle(
                color: AppColors.muted.withOpacity(0.6),
                fontSize: Responsive.getFontSize(context, 14),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _rules.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(context, 0.05),
                      vertical: Responsive.getHeight(context, 0.02),
                    ),
                    child: _RulePage(
                      number: _rules[index]['number'],
                      title: _rules[index]['title'],
                      text: _rules[index]['text'],
                      icon: _rules[index]['icon'],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_rules.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _currentPage == index
                            ? [AppColors.primary, AppColors.secondary]
                            : [AppColors.muted.withOpacity(0.3), AppColors.muted.withOpacity(0.3)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    label: 'НАЗАД',
                    icon: Icons.arrow_back_ios,
                    onTap: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                  ),
                  if (_currentPage == _rules.length - 1)
                    _NavButton(
                      label: 'ПОНЯТНО',
                      icon: Icons.check,
                      isAccent: true,
                      onTap: () => Navigator.of(context).pop(),
                    )
                  else
                    _NavButton(
                      label: 'ДАЛЕЕ',
                      icon: Icons.arrow_forward_ios,
                      onTap: () => _goToPage(_currentPage + 1),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulePage extends StatelessWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _RulePage({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.getWidth(context, 0.15),
          height: Responsive.getWidth(context, 0.15),
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 120, minHeight: 80, maxHeight: 120),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: Responsive.getFontSize(context, 56),
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Responsive.getHeight(context, 0.03)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Responsive.getWidth(context, 0.07),
              height: Responsive.getWidth(context, 0.07),
              constraints: const BoxConstraints(minWidth: 30, maxWidth: 40, minHeight: 30, maxHeight: 40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.getWidth(context, 0.02)),
            Flexible(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.getHeight(context, 0.02)),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: Responsive.getFontSize(context, 14),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isAccent;

  const _NavButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isAccent && enabled
              ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
              : null,
          color: !isAccent && enabled
              ? AppColors.primary.withOpacity(0.15)
              : !isAccent
              ? Colors.transparent
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? isAccent
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.5)
                : AppColors.muted.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label == 'НАЗАД') ...[
              Icon(
                icon,
                size: 14,
                color: enabled ? AppColors.muted : AppColors.muted.withOpacity(0.3),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: enabled
                    ? isAccent
                    ? Colors.white
                    : AppColors.muted
                    : AppColors.muted.withOpacity(0.3),
                fontWeight: FontWeight.w600,
                fontSize: Responsive.getFontSize(context, 12),
                letterSpacing: 2,
              ),
            ),
            if (label != 'НАЗАД') ...[
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 14,
                color: enabled
                    ? isAccent
                    ? Colors.white
                    : AppColors.muted
                    : AppColors.muted.withOpacity(0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedStartButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedStartButton({required this.onTap});

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(context, 0.15),
                vertical: Responsive.getHeight(context, 0.03),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(_glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Text(
                'НАЧАТЬ',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 30),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RulesButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RulesButton({required this.onTap});

  @override
  State<_RulesButton> createState() => _RulesButtonState();
}

class _RulesButtonState extends State<_RulesButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(context, 0.08),
            vertical: Responsive.getHeight(context, 0.02),
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.accent.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered
                  ? AppColors.accent
                  : AppColors.muted.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: Responsive.getFontSize(context, 20),
                color: _isHovered ? AppColors.accent : AppColors.muted,
              ),
              SizedBox(width: Responsive.getWidth(context, 0.02)),
              Text(
                'ПРАВИЛА',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  color: _isHovered ? AppColors.accent : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}