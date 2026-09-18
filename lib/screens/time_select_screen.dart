// lib/screens/time_select_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'pack_select_screen.dart';

class TimeSelectScreen extends StatelessWidget {
  const TimeSelectScreen({super.key});

  final List<Map<String, dynamic>> timeOptions = const [
    {'label': '1:00', 'seconds': 60, 'subtitle': 'Классический формат'},
    {'label': '1:30', 'seconds': 90, 'subtitle': 'Расширенное время'},
    {'label': '2:00', 'seconds': 120, 'subtitle': 'Для новичков'},
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = Responsive.isLandscape(context);

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(context, 0.05)),
            child: Column(
              children: [
                SizedBox(height: Responsive.getHeight(context, 0.04)),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.muted, AppColors.highlight],
                  ).createShader(bounds),
                  child: Text(
                    'ВЫБЕРИТЕ ВРЕМЯ',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 34),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
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
                SizedBox(height: Responsive.getHeight(context, 0.06)),
                Expanded(
                  child: isLandscape
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: timeOptions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final gradients = [
                        [AppColors.primary, AppColors.accent],
                        [AppColors.secondary, AppColors.highlight],
                        [AppColors.tertiary, AppColors.primary],
                      ];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(context, 0.03)),
                        child: _TimeCard(
                          label: option['label'] as String,
                          subtitle: option['subtitle'] as String,
                          seconds: option['seconds'] as int,
                          gradientColors: gradients[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PackSelectScreen(
                                  timeSeconds: option['seconds'] as int,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: timeOptions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final gradients = [
                        [AppColors.primary, AppColors.accent],
                        [AppColors.secondary, AppColors.highlight],
                        [AppColors.tertiary, AppColors.primary],
                      ];

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: Responsive.getHeight(context, 0.02)),
                        child: _TimeCard(
                          label: option['label'] as String,
                          subtitle: option['subtitle'] as String,
                          seconds: option['seconds'] as int,
                          gradientColors: gradients[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PackSelectScreen(
                                  timeSeconds: option['seconds'] as int,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.04)),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.muted),
                  label: Text(
                    'НАЗАД',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: Responsive.getFontSize(context, 16),
                      letterSpacing: 3,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(context, 0.03)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatefulWidget {
  final String label;
  final String subtitle;
  final int seconds;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _TimeCard({
    required this.label,
    required this.subtitle,
    required this.seconds,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<_TimeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isLandscape = Responsive.isLandscape(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: isLandscape ? Responsive.getWidth(context, 0.2) : Responsive.getWidth(context, 0.5),
          height: isLandscape ? Responsive.getHeight(context, 0.3) : Responsive.getHeight(context, 0.25),
          constraints: BoxConstraints(
            minWidth: 150,
            maxWidth: 250,
            minHeight: 200,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered
                  ? widget.gradientColors
                  : AppColors.cardGradient,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? widget.gradientColors[0]
                  : AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: widget.gradientColors[0].withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: Responsive.getFontSize(context, 44),
                color: _isHovered ? Colors.white : AppColors.muted,
              ),
              SizedBox(height: Responsive.getHeight(context, 0.03)),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 52),
                  fontWeight: FontWeight.bold,
                  color: _isHovered ? Colors.white : AppColors.muted,
                ),
              ),
              SizedBox(height: Responsive.getHeight(context, 0.025)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(context, 0.03),
                  vertical: Responsive.getHeight(context, 0.01),
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 13),
                    color: _isHovered ? Colors.white70 : AppColors.muted.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}