import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFADFF2F);
  static const Color backgroundColor = Colors.black;
  static const Color textColor = Colors.white;

  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(color: textColor),
      iconTheme: IconThemeData(color: textColor),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[900],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
      ),
    ),
  );
}