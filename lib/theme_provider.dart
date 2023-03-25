import 'package:flutter/material.dart';
import 'dynamic_ui/type_parser.dart';
import 'storage.dart';
import 'data_type.dart';
import 'db/data_source.dart';

enum ThemeEnum { dark, light, auto, manual }

class ThemeProvider {
  static ThemeEnum manualThemeEnum = ThemeEnum.auto;
  static Brightness deviceBrightness = Brightness.light;

  static void init() {
    Storage().onChange('theme', 'light', (value) {
      deviceBrightness = value == 'light' ? Brightness.light : Brightness.dark;
      DataSource().get('main.json', (data) {
        if (data != null) {
          data['theme'] = value;
          DataSource().set('main.json', data, DataType.template);
        }
      });
    });
  }

  static ThemeData getTheme() {
    ThemeEnum result = manualThemeEnum;
    if (manualThemeEnum == ThemeEnum.auto) {
      result = deviceBrightness == Brightness.dark ? ThemeEnum.dark : ThemeEnum.light;
    }
    switch (result) {
      case ThemeEnum.dark:
        return darkThemeData();
      default:
        return lightThemeData();
    }
  }

  static ThemeData lightThemeData() {
    return ThemeData.light().copyWith(
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
            elevation: 0,
            backgroundColor: TypeParser.parseColor("#f9f9f9"),
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
      floatingActionButtonTheme: ThemeData.light().floatingActionButtonTheme.copyWith(
            backgroundColor: TypeParser.parseColor("#f5f5f5"),
            foregroundColor: Colors.black,
            elevation: 0,
            disabledElevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
          ),
      bottomNavigationBarTheme: ThemeData.light().bottomNavigationBarTheme.copyWith(
            elevation: 0,
            selectedItemColor: Colors.black,
            selectedIconTheme: const IconThemeData(color: Colors.black),
            unselectedIconTheme: IconThemeData(color: Colors.grey[500]),
            backgroundColor: TypeParser.parseColor("#f9f9f9"),
          ),
      scaffoldBackgroundColor: TypeParser.parseColor("#f5f5f5"),
    );
  }

  static ThemeData darkThemeData() {
    return ThemeData.dark().copyWith(
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
            elevation: 0,
            backgroundColor: Colors.grey[900],
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
      floatingActionButtonTheme: ThemeData.dark().floatingActionButtonTheme.copyWith(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            disabledElevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
          ),
      bottomNavigationBarTheme: ThemeData.dark().bottomNavigationBarTheme.copyWith(
            elevation: 0,
            selectedItemColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
            backgroundColor: Colors.grey[900],
          ),
      scaffoldBackgroundColor: Colors.black,
    );
  }
}
