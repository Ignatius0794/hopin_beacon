import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'package:sandbox/core/theme/constants/styles.dart' as style;

@injectable
class AppTheme {
  ThemeData get light => _build(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
            seedColor: style.appColor,
            brightness: Brightness.light,
            surface: style.cardColor),
        scaffoldColor: style.scaffoldBackgroundColor,
      );

  ThemeData get dark => _build(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: style.darkAppColor,
            brightness: Brightness.dark,
            surface: const Color(0xFF1B211F)),
        scaffoldColor: const Color(0xFF101412),
      );

  ThemeData _build(
      {required Brightness brightness,
      required ColorScheme colorScheme,
      required Color scaffoldColor}) {
    final outline = colorScheme.outline.withValues(alpha: 0.55);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: style.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
              color: colorScheme.onSurface,
              fontFamily: style.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700)),
      cardTheme: CardTheme(
          elevation: 0,
          color: colorScheme.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: outline))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: outline)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(64, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700))),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? colorScheme.onPrimary
                : colorScheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest),
      ),
    );
  }
}
