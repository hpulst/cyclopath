import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      // primarySwatch: Colors.grey,
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
          primary: Colors.grey.shade900,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            // side: BorderSide(
            //   width: 2,
            // style: BorderStyle.solid,
            // color: Colors,
            // ),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryColor,
        // size: 30,
      ),
    );
  }

  static const _primaryColor = Colors.black;
  static const _accentColor = Colors.white;
}
