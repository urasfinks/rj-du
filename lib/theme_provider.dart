import 'package:flutter/material.dart';

import 'dynamic_ui/type_parser.dart';

class ThemeProvider {
  static int alpha = 125;
  static double blur = 15;

  static Brightness deviceBrightness = Brightness.light;

  static ThemeData lightThemeData() {
    Color parseColor = TypeParser.parseColor("#f4f4f4")!;
    List<Color> cur = [
      parseColor,
      parseColor.darkness(20),
      parseColor.darkness(40),
    ];
    ThemeData themeData = ThemeData.light();
    print("light");
    return get(cur, themeData);
  }

  static ThemeData darkThemeData() {
    List<Color> cur = [
      Colors.black,
      Colors.black.lightness(20),
      Colors.black.lightness(40),
    ];
    ThemeData themeData = ThemeData.dark();
    print("dark");
    return get(cur, themeData);
  }

  static get(
    List<Color> cur,
    ThemeData themeData,
  ) {
    int light = 10;
    return themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: cur[0].lightness(light).withAlpha(alpha),
        foregroundColor: cur[0].inverse(),
        iconTheme: IconThemeData(color: cur[0].inverse()),
      ),
      colorScheme: themeData.colorScheme.copyWith(
        background: cur[0],
        onBackground: cur[0].lightness(light),
        // text
        primary: cur[1].inverse().darkness(light),
        // background
        primaryContainer: cur[1],
        //onBackground
        onPrimary: cur[1].lightness(light),

        //text
        secondary: cur[2].inverse().darkness(light),
        //background
        secondaryContainer: cur[2],
        //onBackground
        onSecondary: cur[2].lightness(light),

        inversePrimary: cur[0].inverse(),
      ),
      floatingActionButtonTheme: themeData.floatingActionButtonTheme.copyWith(
        backgroundColor: cur[0],
        foregroundColor: cur[0].inverse(),
        elevation: 0,
        disabledElevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      bottomNavigationBarTheme: themeData.bottomNavigationBarTheme.copyWith(
        elevation: 0,
        selectedItemColor: cur[0].inverse(),
        selectedIconTheme: IconThemeData(color: cur[1].inverse().darkness(light)),
        unselectedIconTheme: IconThemeData(color: cur[2].inverse().darkness(light)),
        backgroundColor: cur[0].lightness(light).withAlpha(alpha),
      ),
      scaffoldBackgroundColor: cur[0],
      textSelectionTheme: themeData.textSelectionTheme.copyWith(
        cursorColor: cur[0].inverse(),
      ),
    );
  }
}

extension HexColor on Color {
  Color lightness(int prc) {
    List<int> l = getChannel();
    List<int> result = [];
    for (int cur in l) {
      //double x = (prc * (255 - cur) / 100) + cur;
      double x = cur + (prc * 255 / 100);
      if (x > 255) {
        x = 255;
      }
      result.add(x.toInt());
    }
    return fromRGB(result);
  }

  Color darkness(int prc) {
    List<int> l = getChannel();
    List<int> result = [];
    for (int cur in l) {
      double x = cur - (prc * 255 / 100);
      if (x < 0) {
        x = 0;
      }
      result.add(x.toInt());
    }
    return fromRGB(result);
  }

  Color inverse() {
    List<int> l = getChannel();
    List<int> result = [];
    for (int cur in l) {
      result.add(255 - cur);
    }
    return fromRGB(result);
  }

  List<int> getChannel({bool leadingHashSign = true}) {
    return [red, green, blue];
  }

  static Color fromRGB(List<int> l) {
    return Color.fromRGBO(l[0], l[1], l[2], 1);
  }
}
