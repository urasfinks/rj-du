import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../iterator.dart';

class IteratorThemeLoader {
  static void load(Map<String, String> map, String extra) {
    List<String> list = [];
    for (MapEntry<String, dynamic> item in map.entries) {
      try {
        list.add(item.key);
        Map<String, dynamic> parseTheme = json.decode(item.value);
        Iterator.theme[item.key] = parseTheme;
      } catch (e) {
        if (kDebugMode) {
          print("IteratorThemeLoader exeption: $e");
        }
      }
    }
    if (kDebugMode) {
      print("IteratorThemeLoader.load()::$extra $list");
    }
  }
}
