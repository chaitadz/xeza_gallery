import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getDarkTheme() {
    const fontFamily = 'Poppins';

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontFamily: fontFamily),
        bodyMedium: TextStyle(fontFamily: fontFamily),
        bodySmall: TextStyle(fontFamily: fontFamily),
        labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      ),
    );
  }
}