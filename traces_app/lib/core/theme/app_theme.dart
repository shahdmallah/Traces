import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1A6B4A);
  static const _accentColor  = Color(0xFFE8A838);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ).copyWith(secondary: _accentColor),
    fontFamily: 'TracesDisplay',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ).copyWith(secondary: _accentColor),
    fontFamily: 'TracesDisplay',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}
