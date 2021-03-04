import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: _primaryColor,
      accentColor: _accentColor,
    );
  }

  static const _primaryColor = Colors.black;
  static const _accentColor = Colors.white;
}
