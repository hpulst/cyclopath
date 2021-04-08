import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      buttonColor: _primaryColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: _primaryColor,
          onPrimary: _accentColor,
          textStyle: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: Colors.black.withOpacity(0.7),
      ),
    );
  }

  static const _primaryColor = Colors.black;
  static const _accentColor = Colors.white;
}
