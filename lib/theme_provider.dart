import 'package:flutter/material.dart';

class ThemeProvider {
  static int alpha = 125;
  static double blur = 15;

  static Brightness deviceBrightness = Brightness.light;

  static List<Color> grad = [];

  static ThemeData lightThemeData() {
    List<Color> cur = [
      Colors.grey[200]!,
      Colors.grey[50]!,
      Colors.grey[500]!,
      Colors.black,
    ];
    ThemeData themeData = ThemeData.light();
    return get(cur, themeData);
  }

  static ThemeData darkThemeData() {
    List<Color> cur = [
      Colors.black,
      Colors.grey[900]!,
      Colors.grey[400]!,
      Colors.white,
    ];
    cur.addAll(grad);
    ThemeData themeData = ThemeData.dark();
    return get(cur, themeData);
  }

  static get(List<Color> cur, ThemeData themeData) {
    return themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: cur[1].withAlpha(alpha),
        foregroundColor: cur[3],
        iconTheme: IconThemeData(color: cur[3]),
      ),
      colorScheme: themeData.colorScheme.copyWith(
        background: cur[0],
        primary: cur[0],
        onBackground: cur[1],
        secondary: cur[2],
        inversePrimary: cur[3],
      ),
      floatingActionButtonTheme: themeData.floatingActionButtonTheme.copyWith(
        backgroundColor: cur[0],
        foregroundColor: cur[3],
        elevation: 0,
        disabledElevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      bottomNavigationBarTheme: themeData.bottomNavigationBarTheme.copyWith(
        elevation: 0,
        selectedItemColor: cur[3],
        selectedIconTheme: IconThemeData(color: cur[3]),
        unselectedIconTheme: IconThemeData(color: cur[2]),
        backgroundColor: cur[1].withAlpha(alpha),
      ),
      scaffoldBackgroundColor: cur[0],
      textSelectionTheme: themeData.textSelectionTheme.copyWith(
        cursorColor: cur[3],
      ),
    );
  }
}
