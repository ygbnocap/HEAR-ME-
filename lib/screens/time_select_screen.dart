import 'package:flutter/material.dart';
import '../theme/gameplay_theme.dart';
import '../widgets/studio_components.dart';
import 'pack_select_screen.dart';

class TimeSelectScreen extends StatelessWidget {
  const TimeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const options = [
      (label: '1:00', seconds: 60, subtitle: 'Классический формат'),
      (label: '1:30', seconds: 90, subtitle: 'Расширенное время'),
      (label: '2:00', seconds: 120, subtitle: 'Для новичков'),
    ];
    return StudioPage(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StudioHeader(
          title: 'ВЫБЕРИТЕ ВРЕМЯ', onBack: () => Navigator.pop(context)),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 &&
                MediaQuery.textScalerOf(context).scale(16) <= 22
            ? 3
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final option in options)
            SizedBox(
                width: width,
                child: Material(
                  color: GameplayTheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: GameplayTheme.outline)),
                  clipBehavior: Clip.antiAlias,
                  child: Semantics(
                      button: true,
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PackSelectScreen(
                                    timeSeconds: option.seconds))),
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      color: GameplayTheme.primary, size: 24),
                                  const SizedBox(height: 12),
                                  Text(option.label,
                                      style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: GameplayTheme.text)),
                                  const SizedBox(height: 8),
                                  Text(option.subtitle,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                          color: GameplayTheme.secondary)),
                                ])),
                      )),
                )),
        ]);
      }),
    ]));
  }
}
