import 'dart:convert';

import 'package:rjdu/util.dart';

import 'db/data_source.dart';
import 'storage.dart';

class Translate {
  static final Translate _singleton = Translate._internal();
  Map<String, dynamic> map = {};

  factory Translate() {
    return _singleton;
  }

  Translate._internal();

  void init() {
    Util.p("Translate.init()");
    DataSource().subscribe("Translate.json", (uuid, data) {
      if (data != null) {
        map = data;
      }
    });
  }

  String get(List<String> args) {
    if (args.length == 1) {
      return _get(args[0]);
    } else if (args.length == 2) {
      return _get(args[0], args[1]);
    } else {
      return "Undefined arguments size: $args";
    }
  }

  String _get(String id, [String? language]) {
    language ??= Storage().get("language", "ru");
    if (map.containsKey(id)) {
      Map<String, dynamic> dict = map[id] as Map<String, dynamic>;
      if (dict.containsKey(language)) {
        return dict[language]!;
      } else if (dict.containsKey("en")) {
        return dict["en"]!;
      } else {
        return json.encode(dict);
      }
    }
    return "Undefined translate [$id]";
  }
}
