import 'package:flutter/material.dart';
import 'dynamic_ui/type_parser.dart';

class ThemeProvider {
  static int alpha = 175;
  static double blur = 15;

  static Brightness? brightness;

  static Color projectPrimary = Colors.blue[600]!;
  static Color projectPrimaryText = Colors.white;
  static Color projectSecondary = Colors.amber;
  static Color projectSecondaryText = Colors.white;

  static Brightness deviceBrightness = Brightness.light;

  static setColor(String primary, String primaryText, String secondary, String secondaryText) {
    projectPrimary = TypeParser.parseColor(primary) ?? Colors.blue[600]!;
    projectPrimaryText = TypeParser.parseColor(primaryText) ?? Colors.white;
    projectSecondary = TypeParser.parseColor(secondary) ?? Colors.amber;
    projectSecondaryText = TypeParser.parseColor(secondaryText) ?? Colors.white;
  }

  static Map<Brightness, List<Color>> mapColor = {
    Brightness.dark: [
      Colors.black,
      Colors.black.lightness(25),
      Colors.black.lightness(50),
    ],
    Brightness.light: [
      Colors.white,
      Colors.white.darkness(15),
      Colors.white.darkness(30),
    ]
  };

  static ThemeData lightThemeData() {
    ThemeData themeData = ThemeData.light();
    return get(mapColor[Brightness.light]!, themeData, false);
  }

  static Color getThemeColor() {
    return mapColor[brightness]!.first;
  }

  static ThemeData darkThemeData() {
    ThemeData themeData = ThemeData.dark();
    return get(mapColor[Brightness.dark]!, themeData, true);
  }

  static get(List<Color> cur, ThemeData themeData, bool dark) {
    int light = 15;
    return themeData.copyWith(
      appBarTheme: themeData.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: cur[0].lightness(light).withAlpha(alpha),
        foregroundColor: cur[0].inverse(),
        iconTheme: IconThemeData(color: cur[0].inverse()),
      ),
      colorScheme: themeData.colorScheme.copyWith(
        inversePrimary: cur[0].inverse(),
        background: cur[0],
        //Общие правила для первго слоя, так как фон для light темы серый
        onBackground: cur[0].lightness(light),

        // text
        primary: cur[1].inverse(),
        // background
        primaryContainer: cur[1],
        //onBackground
        onPrimary: dark ? cur[1].lightness(light) : cur[1].darkness(light),

        //text
        secondary: cur[2].inverse(),
        //background
        secondaryContainer: cur[2],
        //onBackground
        onSecondary: dark ? cur[2].lightness(light) : cur[2].darkness(light),
      ),
      floatingActionButtonTheme: themeData.floatingActionButtonTheme.copyWith(
        backgroundColor: cur[0].lightness(light),
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
        selectedIconTheme: IconThemeData(color: cur[0].inverse().darkness(light)),
        unselectedIconTheme:
            IconThemeData(color: dark ? cur[2].inverse().darkness(light) : cur[2].inverse().lightness(light)),
        backgroundColor: cur[0].lightness(light).withAlpha(alpha),
      ),
      scaffoldBackgroundColor: dark ? cur[0] : TypeParser.parseColor("#f2f2f2")!,
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
