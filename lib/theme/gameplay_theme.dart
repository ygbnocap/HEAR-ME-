import 'package:flutter/material.dart';

/// Scoped to gameplay: setup, editors and summaries retain their own theme.
abstract final class GameplayTheme {
  static const background = Color(0xFF101820);
  static const surface = Color(0xFF192630);
  static const raised = Color(0xFF223540);
  static const outline = Color(0xFF8299A6);
  static const text = Color(0xFFF4F7F8);
  static const secondary = Color(0xFFB7C7D0);
  static const primary = Color(0xFFFFD166);
  static const onPrimary = Color(0xFF17222B);
  static const easy = Color(0xFF78D6C6);
  static const medium = Color(0xFFA5C9F5);
  static const hard = Color(0xFFD2B5F1);
  static const error = Color(0xFFFFADB0);

  static ThemeData data(BuildContext context) {
    final base = Theme.of(context);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        secondary: easy,
        surface: surface,
        onSurface: text,
        error: error,
        outline: outline,
      ),
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(48, 52),
          side: const BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
