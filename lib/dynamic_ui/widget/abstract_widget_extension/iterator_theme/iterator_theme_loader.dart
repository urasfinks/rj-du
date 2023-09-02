import 'dart:convert';

import 'package:rjdu/util.dart';
import '../iterator.dart';

class IteratorThemeLoader {
  static void load(Map<String, String> map, String extra) {
    List<String> list = [];
    for (MapEntry<String, dynamic> item in map.entries) {
      try {
        list.add(item.key);
        Map<String, dynamic> parseTheme = json.decode(item.value);
        Iterator.theme[item.key] = parseTheme;
      } catch (e, stacktrace) {
        Util.printStackTrace("IteratorThemeLoader", e, stacktrace);
      }
    }
    Util.p("IteratorThemeLoader.load()::$extra $list");
  }
}
