import 'package:flutter/material.dart';
import '../theme/gameplay_theme.dart';

/// Setup and editor surfaces share the established Night Studio palette.
class StudioTheme extends StatelessWidget {
  const StudioTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
        data: GameplayTheme.data(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: GameplayTheme.surface,
            labelStyle:
                const TextStyle(color: GameplayTheme.secondary, fontSize: 16),
            helperStyle:
                const TextStyle(color: GameplayTheme.secondary, fontSize: 14),
            errorStyle:
                const TextStyle(color: GameplayTheme.error, fontSize: 14),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: GameplayTheme.outline),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: GameplayTheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: GameplayTheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: GameplayTheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: GameplayTheme.primary, width: 2),
            ),
          ),
        ),
        child: child,
      );
}

class StudioPage extends StatelessWidget {
  const StudioPage(
      {super.key,
      required this.child,
      this.center = false,
      this.maxWidth = 960});
  final Widget child;
  final bool center;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => StudioTheme(
        child: Scaffold(
          backgroundColor: GameplayTheme.background,
          body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight - 32)
                                .clamp(0, double.infinity)),
                        child: Align(
                          alignment:
                              center ? Alignment.center : Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child:
                                SizedBox(width: double.infinity, child: child),
                          ),
                        ),
                      ),
                    )),
          ),
        ),
      );
}

class StudioHeader extends StatelessWidget {
  const StudioHeader({super.key, required this.title, this.onBack});
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          if (onBack != null) ...[
            IconButton(
                onPressed: onBack,
                tooltip: 'Назад',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.arrow_back, color: GameplayTheme.text)),
            const SizedBox(width: 8),
          ],
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: GameplayTheme.text))),
        ]),
      );
}

class StudioSurface extends StatelessWidget {
  const StudioSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: GameplayTheme.surface,
            borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}
