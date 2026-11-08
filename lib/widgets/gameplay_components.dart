import 'package:flutter/material.dart';
import '../models/question_pack.dart';
import '../theme/gameplay_theme.dart';

String gameplayTime(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// One scrollable fallback contains the HUD too, so large text cannot consume
/// the entire viewport before the question or the last category is reached.
class GameplayPage extends StatelessWidget {
  const GameplayPage({super.key, required this.hud, required this.child});
  final Widget hud;
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
        data: GameplayTheme.data(context),
        child: Scaffold(
          backgroundColor: GameplayTheme.background,
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final fallback = constraints.maxHeight < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 22;
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  hud,
                  const SizedBox(height: 12),
                  if (fallback) child else Expanded(child: child),
                ],
              );
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1008),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: fallback
                        ? SingleChildScrollView(child: content)
                        : content,
                  ),
                ),
              );
            }),
          ),
        ),
      );
}

class GameplayHud extends StatelessWidget {
  const GameplayHud({super.key, required this.items, this.onExit});
  final List<Widget> items;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: GameplayTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 8,
            children: [
              ...items,
              if (onExit != null)
                TextButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.exit_to_app, size: 20),
                  label: const Text('ВЫЙТИ'),
                ),
            ],
          ),
        ),
      );
}

class GameplayStatus extends StatelessWidget {
  const GameplayStatus({
    super.key,
    required this.label,
    required this.value,
    this.urgent = false,
  });
  final String label;
  final String value;
  final bool urgent;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: MergeSemantics(
          child: Wrap(
            spacing: 8,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: GameplayTheme.secondary)),
              Text(value,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    color: urgent ? GameplayTheme.error : GameplayTheme.text,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ],
          ),
        ),
      );
}

class GameplayCategorySelection extends StatelessWidget {
  const GameplayCategorySelection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.counts,
    required this.onSelected,
    this.showBonus = false,
  });
  final String title;
  final String subtitle;
  final List<int> counts;
  final ValueChanged<Difficulty> onSelected;
  final bool showBonus;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 660 &&
              MediaQuery.textScalerOf(context).scale(16) <= 21;
          final cards = List.generate(3, (index) {
            final difficulty = Difficulty.values[index];
            return _CategoryCard(
              difficulty: difficulty,
              title: const ['ЛЁГКИЕ', 'СРЕДНИЕ', 'СЛОЖНЫЕ'][index],
              color: const [
                GameplayTheme.easy,
                GameplayTheme.medium,
                GameplayTheme.hard
              ][index],
              count: counts[index],
              bonus: showBonus ? '+${(index + 1) * 30} с' : null,
              onTap: counts[index] > 0 ? () => onSelected(difficulty) : null,
            );
          });
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: GameplayTheme.text)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: GameplayTheme.secondary)),
              const SizedBox(height: 16),
              if (columns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                )
              else
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  cards[i],
                ],
            ],
          );
          return constraints.hasBoundedHeight
              ? SingleChildScrollView(child: content)
              : content;
        },
      );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.difficulty,
      required this.title,
      required this.color,
      required this.count,
      required this.bonus,
      required this.onTap});
  final Difficulty difficulty;
  final String title;
  final Color color;
  final int count;
  final String? bonus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: GameplayTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              BorderSide(color: onTap == null ? GameplayTheme.outline : color),
        ),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          enabled: onTap != null,
          child: InkWell(
            key: ValueKey('gameplay-category-${difficulty.name}'),
            onTap: onTap,
            focusColor: GameplayTheme.outline.withValues(alpha: 0.35),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: 64, minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: onTap == null
                                ? GameplayTheme.secondary
                                : color)),
                    const SizedBox(height: 8),
                    Text(count > 0 ? 'Осталось $count' : 'Вопросы закончились',
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: GameplayTheme.secondary)),
                    if (bonus != null) ...[
                      const SizedBox(height: 8),
                      Text(bonus!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: GameplayTheme.text)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class GameplayQuestion extends StatelessWidget {
  const GameplayQuestion(
      {super.key,
      required this.text,
      required this.showAnswer,
      required this.actions,
      this.status});
  final String text;
  final bool showAnswer;
  final Widget? status;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final body = Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            text,
            key: ValueKey(showAnswer ? 'gameplay-answer' : 'gameplay-question'),
            style: const TextStyle(
                fontSize: 24,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: GameplayTheme.onPrimary),
          ),
        );
        Widget paper(Widget child) => Material(
              key: const ValueKey('gameplay-question-paper'),
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: child,
            );
        final buttons = Wrap(spacing: 12, runSpacing: 12, children: actions);
        final bounded = constraints.hasBoundedHeight;
        return DecoratedBox(
          decoration: BoxDecoration(
              color: GameplayTheme.surface,
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (status != null) ...[status!, const SizedBox(height: 8)],
                if (bounded)
                  Expanded(
                    child: paper(SingleChildScrollView(
                      key: ValueKey(showAnswer),
                      child: Align(alignment: Alignment.topLeft, child: body),
                    )),
                  )
                else
                  paper(body),
                const SizedBox(height: 16),
                buttons,
              ],
            ),
          ),
        );
      });
}

class GameplayCountdown extends StatelessWidget {
  const GameplayCountdown({super.key, required this.value});
  final int value;

  @override
  Widget build(BuildContext context) => Center(
        child: Text('$value',
            style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w700,
                color: GameplayTheme.primary)),
      );
}
