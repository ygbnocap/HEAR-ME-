import 'package:flutter/material.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
import 'time_select_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) => StudioPage(
        center: true,
        maxWidth: 640,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.headphones, size: 48, color: GameplayTheme.primary),
          const SizedBox(height: 16),
          const Text('КАК',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: GameplayTheme.text)),
          const Text('СЛЫШНО?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: GameplayTheme.primary)),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TimeSelectScreen())),
              child: const Text('НАЧАТЬ')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const RulesCarouselDialog()),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('ПРАВИЛА')),
        ]),
      );
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
      'title': 'Командная игра',
      'text':
          '"Как слышно?" — командная игра. Побеждают или проигрывают все вместе. Результат общий, ответственность общая.',
      'icon': Icons.groups_outlined
    },
    {
      'title': 'Наушники обязательны',
      'text':
          'Каждый участник надевает наушники с громкой музыкой до старта вопроса и снимает их только после окончания ответа.',
      'icon': Icons.headphones_outlined
    },
    {
      'title': 'Поле карточек',
      'text':
          'На столе 12 карточек: 4 лёгких, 4 средних и 4 сложных вопроса. Игроки по очереди выбирают любую открытую карточку.',
      'icon': Icons.grid_view_outlined
    },
    {
      'title': 'Условие балла',
      'text':
          'Балл засчитывается только если все участники дали одинаковый и при этом правильный ответ. Согласованность важнее скорости.',
      'icon': Icons.check_circle_outline
    },
    {
      'title': 'Время на ответ',
      'text':
          'На объяснение вопроса участникам даётся выбранное время: 1:00, 1:30 или 2:00. Следи за таймером!',
      'icon': Icons.timer_outlined
    },
    {
      'title': 'Система очков',
      'text':
          'За правильный ответ начисляются время, которое будет использовано в финальной игре: лёгкий вопрос — 0:30, средний — 1:00, сложный — 1:30.',
      'icon': Icons.stars_outlined
    },
    {
      'title': '7 раундов',
      'text':
          'Основная игра длится ровно 7 раундов. Необязательно открывать все карточки — стратегия выбора имеет значение.',
      'icon': Icons.format_list_numbered
    },
    {
      'title': 'Финальный раунд',
      'text':
          'После основной части все игроки тайно голосуют: кто лучше всего проявил себя, и кто — хуже всего. Два выбранных игрока разыгрывают оставшиеся 3 из 5 вопросов в дуэли.',
      'icon': Icons.how_to_vote_outlined
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(page);
    } else {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) => StudioTheme(
        child: Dialog(
          backgroundColor: GameplayTheme.surface,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  const Expanded(
                      child: Text('ПРАВИЛА ИГРЫ',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: GameplayTheme.text))),
                  IconButton(
                      tooltip: 'Закрыть правила',
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ]),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${_currentPage + 1} / ${_rules.length}',
                        style: const TextStyle(
                            fontSize: 14, color: GameplayTheme.secondary))),
                const SizedBox(height: 12),
                Expanded(
                    child: PageView.builder(
                  controller: _pageController,
                  itemCount: _rules.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_rules[index]['icon'] as IconData,
                              size: 32, color: GameplayTheme.primary),
                          const SizedBox(height: 12),
                          Text(_rules[index]['title'] as String,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: GameplayTheme.text)),
                          const SizedBox(height: 12),
                          Text(_rules[index]['text'] as String,
                              style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: GameplayTheme.secondary)),
                        ]),
                  ),
                )),
                Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _currentPage > 0
                              ? () => _goToPage(_currentPage - 1)
                              : null,
                          child: const Text('НАЗАД')),
                      FilledButton(
                          onPressed: _currentPage == _rules.length - 1
                              ? () => Navigator.pop(context)
                              : () => _goToPage(_currentPage + 1),
                          child: Text(_currentPage == _rules.length - 1
                              ? 'ПОНЯТНО'
                              : 'ДАЛЕЕ')),
                    ]),
              ]),
            ),
          ),
        ),
      );
}
