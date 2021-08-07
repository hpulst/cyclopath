import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members

ThemeData light() {
  return ThemeData(
    primaryColor: _primaryColor,
    backgroundColor: _secondaryColor,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: _primaryColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: _primaryColor,
        onPrimary: _secondaryColor,
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
      size: 30,
    ),
  );
}

const _primaryColor = Colors.black;
const _secondaryColor = Colors.white;
