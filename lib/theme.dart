import 'package:flutter/material.dart';

class ReflexColors {
  static const background = Color(0xFF101114);
  static const surface = Color(0xFF1B1B20);
  static const surfaceRaised = Color(0xFF232328);
  static const nav = Color(0xFF1C1B20);
  static const orange = Color(0xFFFF7517);
  static const orangeLight = Color(0xFFFF9A48);
  static const text = Color(0xFFF4F0EC);
  static const muted = Color(0xFF9B9693);
  static const line = Color(0xFF302F33);
  static const success = Color(0xFF8CCB9A);
}

class ReflexTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: ReflexColors.background,
    colorScheme: const ColorScheme.dark(
      primary: ReflexColors.orange,
      secondary: ReflexColors.orangeLight,
      surface: ReflexColors.surface,
      error: Color(0xFFFF6B6B),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: ReflexColors.text, fontSize: 16),
      bodyMedium: TextStyle(color: ReflexColors.text, fontSize: 14),
      bodySmall: TextStyle(color: ReflexColors.muted, fontSize: 12),
      titleLarge: TextStyle(
        color: ReflexColors.text,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
      titleMedium: TextStyle(
        color: ReflexColors.text,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ReflexColors.surfaceRaised,
      hintStyle: const TextStyle(color: ReflexColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ReflexColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: ReflexColors.orange, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.4),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ReflexColors.surfaceRaised,
      contentTextStyle: TextStyle(color: ReflexColors.text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
