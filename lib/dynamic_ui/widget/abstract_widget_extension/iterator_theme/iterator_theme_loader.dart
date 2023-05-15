import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../iterator.dart';

class IteratorThemeLoader {
  static void load(Map<String, String> map) {
    for (MapEntry<String, dynamic> item in map.entries) {
      try {
        if (kDebugMode) {
          print("IteratorThemeLoader.load(${item.key})");
        }
        Map<String, dynamic> parseTheme = json.decode(item.value);
        Iterator.theme[item.key] = parseTheme;
      } catch (e) {
        if (kDebugMode) {
          print("IteratorThemeLoader exeption: $e");
        }
      }
    }
  }
}
