import 'package:flutter/material.dart';
import 'dynamic_ui/type_parser.dart';

class ThemeProvider {

  static int alpha = 125;
  static double blur = 15;

  static Brightness deviceBrightness = Brightness.light;

  static ThemeData lightThemeData() {
    return ThemeData.light().copyWith(
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
            elevation: 0,
            backgroundColor: TypeParser.parseColor("#f9f9f9")?.withAlpha(alpha),
            foregroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
      colorScheme: ThemeData.light().colorScheme.copyWith(
            background: TypeParser.parseColor("#f5f5f5"),
            primary: Colors.white,
            secondary: Colors.grey[700],
            inversePrimary: Colors.black,
            onBackground: TypeParser.parseColor("#ffffff"), //e9e9eb
          ),
      floatingActionButtonTheme:
          ThemeData.light().floatingActionButtonTheme.copyWith(
                backgroundColor: TypeParser.parseColor("#f5f5f5"),
                foregroundColor: Colors.black,
                elevation: 0,
                disabledElevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
              ),
      bottomNavigationBarTheme:
          ThemeData.light().bottomNavigationBarTheme.copyWith(
                elevation: 0,
                selectedItemColor: Colors.black,
                selectedIconTheme: const IconThemeData(color: Colors.black),
                unselectedIconTheme: IconThemeData(color: Colors.grey[500]),
                backgroundColor: TypeParser.parseColor("#f9f9f9")?.withAlpha(alpha),
              ),
      scaffoldBackgroundColor: TypeParser.parseColor("#f5f5f5"),
      textSelectionTheme: ThemeData.dark().textSelectionTheme.copyWith(
            cursorColor: Colors.black,
          ),
    );
  }

  static ThemeData darkThemeData() {
    return ThemeData.dark().copyWith(
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
            elevation: 0,
            backgroundColor: Colors.grey[900]?.withAlpha(alpha),
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
      colorScheme: ThemeData.dark().colorScheme.copyWith(
            background: Colors.black,
            primary: Colors.black,
            secondary: Colors.grey[500],
            inversePrimary: Colors.white,
            onBackground: Colors.grey[900],
          ),
      floatingActionButtonTheme:
          ThemeData.dark().floatingActionButtonTheme.copyWith(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledElevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
              ),
      bottomNavigationBarTheme:
          ThemeData.dark().bottomNavigationBarTheme.copyWith(
                elevation: 0,
                selectedItemColor: Colors.white,
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
                backgroundColor: Colors.grey[900]?.withAlpha(alpha),
              ),
      scaffoldBackgroundColor: Colors.black,
      textSelectionTheme: ThemeData.dark().textSelectionTheme.copyWith(
            cursorColor: Colors.white,
          ),
    );
  }
}
