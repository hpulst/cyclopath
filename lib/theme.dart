import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      buttonColor: _primaryColor,
      buttonTheme: const ButtonThemeData(buttonColor: _primaryColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: _primaryColor,
          onPrimary: _accentColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryColor,
        // size: 30,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: Colors.black.withOpacity(0.7),
      ),
    );
  }

  static const _primaryColor = Colors.black;
  static const _accentColor = Colors.white;
}
