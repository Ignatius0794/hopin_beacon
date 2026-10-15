import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'package:qbyt/core/theme/constants/styles.dart' as style;

@injectable
class AppTheme {
  ThemeData get light => ThemeData(
        fontFamily: style.fontFamily,
        scaffoldBackgroundColor: style.scaffoldBackgroundColor,
        colorScheme: const ColorScheme.light(
          primary: style.appColor,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: style.appColor,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: style.fontFamily,
          ),
        ),
        useMaterial3: true,
      );
}
