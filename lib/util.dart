import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/util/template.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:uuid/uuid.dart';

import 'data_type.dart';
import 'global_settings.dart';

class Util {
  static Base64Codec base64 = const Base64Codec();

  static Uuid uuidObject = const Uuid();

  static Future<dynamic> asyncInvokeIsolate(Function(dynamic arg) fn, dynamic arg) {
    return compute(fn, arg);
  }

  static void log(
    String mes, {
    String? type,
    StackTrace? stackTrace,
    String? correlation,
    bool stack = false,
  }) {
    if (kDebugMode && GlobalSettings().debug) {
      String result = "";
      if (stack == true && stackTrace == null) {
        stackTrace = StackTrace.current;
      }
      String qType = type ?? "info";
      result += LoggerMsg.find(qType).wrap("[$qType]");
      //result += (Util.lPad("", pad: 10 - qType.length, char: " "));
      result += (" ");
      result += LoggerMsg.Gray.wrap("${DateTime.now()} ");
      if (correlation != null) {
        result += LoggerMsg.Cyan.wrap(correlation);
        result += " ";
      }
      result += LoggerMsg.Default.wrap(mes);
      if (stackTrace != null) {
        result += "\n";
        result += LoggerMsg.Red.wrap(stackTrace.toString());
      }
      stdout.writeln(result);
    }
  }

  static void p(dynamic mes, [stack = false, int maxFrames = 7]) {
    if (kDebugMode && GlobalSettings().debug) {
      log(mes, stack: stack);
    }
  }

  static bool isIOs() {
    return Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static getPlatformName() {
    return Platform.operatingSystem;
  }

  static ScrollPhysics? getPhysics() {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  static String template(String template, DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool autoEscape = true, debug = false]) {
    return Template.template(template, dynamicUIBuilderContext, autoEscape, debug);
  }

  static String jsonEncode(dynamic object, [bool pretty = false]) {
    return pretty ? jsonPretty(object) : json.encode(object);
  }

  static String jsonPretty(dynamic object) {
    const JsonEncoder encoder = JsonEncoder.withIndent("  ");
    return encoder.convert(object);
  }

  static String jsonStringEscape(String raw) {
    String escaped = raw;
    escaped = escaped.replaceAll("\\", "\\\\");
    escaped = escaped.replaceAll("\"", "\\\"");
    escaped = escaped.replaceAll("\b", "\\b");
    escaped = escaped.replaceAll("\f", "\\f");
    escaped = escaped.replaceAll("\n", "\\n");
    escaped = escaped.replaceAll("\r", "\\r");
    escaped = escaped.replaceAll("\t", "\\t");
    return escaped;
  }

  static Map<String, dynamic> merge(Map<String, dynamic> def, Map<String, dynamic>? input) {
    if (input == null || input.isEmpty) {
      return def;
    }
    for (var item in input.entries) {
      def[item.key] = item.value;
    }
    return def;
  }

  static dynamic listGet(List list, int index, dynamic def) {
    if (list.asMap().containsKey(index)) {
      return list[index];
    }
    return def;
  }

  static String lPad(String input, {int pad = 0, String char = "0"}) => input.padLeft(pad, char);

  static String rPad(String input, {int pad = 0, String char = "0"}) => input.padRight(pad, char);

  static bool isIndexKey(dynamic data) {
    if (data.runtimeType.toString().contains("Map<")) {
      Map x = data;
      for (String s in x.keys) {
        if (!isNumeric(s)) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  static List<dynamic> getListFromMapOrString(dynamic data) {
    List list = [];
    if (data.runtimeType.toString().startsWith("String")) {
      String x = data;
      if (x.contains(",")) {
        list.addAll(x.split(","));
      } else {
        list.add(data);
      }
    } else if (isIndexKey(data)) {
      Map<String, dynamic> x = data;
      for (var item in x.entries) {
        list.add(item.value);
      }
    }
    return list;
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    if (s == "NaN") {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static int getTimestampMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static int getTimestamp() {
    int microsecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    return microsecondsSinceEpoch ~/ 1000;
  }

  static Key getKey() {
    return UniqueKey();
  }

  static DataType dataTypeValueOf(String? val) {
    if (val == null) {
      return DataType.any;
    }
    List<DataType> values = DataType.values;
    String find = "DataType.$val";
    for (DataType dataType in values) {
      if (dataType.toString() == find) {
        return dataType;
      }
    }
    return DataType.any;
  }

  static bool containsKeys(Map<String, dynamic> map, List<String> keys) {
    for (String key in keys) {
      if (!map.containsKey(key)) {
        return false;
      }
    }
    return true;
  }

  static asyncInvoke(Function(dynamic args) fn, dynamic args) async {
    try {
      await Future<void>.delayed(Duration.zero);
      fn(args);
    } catch (error, stackTrace) {
      Util.log("Util.asyncInvoke(); Error: $error", stackTrace: stackTrace, type: "error");
    }
  }

  static List<dynamic> getMutableList(List? list) {
    return list == null ? [] : json.decode(json.encode(list));
  }

  static Map<String, dynamic> getMutableMap(Map? map) {
    return map == null ? {} : json.decode(json.encode(map));
  }

  static T? enumFromString<T>(Iterable<T> values, String value) {
    return values.firstWhere((type) => type.toString().split(".").last == value);
  }

  static Map<String, dynamic> convertMap(Map<dynamic, dynamic> map) {
    map.forEach((key, value) {
      if (value is Map) {
        // it's a map, process it
        value = convertMap(value);
      }
    });
    // use .from to ensure the keys are Strings
    return Map<String, dynamic>.from(map);
    // more explicit alternative way:
    // return Map.fromEntries(map.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)));
  }

  static Map<String, List<String>> convertMapStringListString(Map<String, dynamic> map) {
    for (MapEntry<String, dynamic> item in map.entries) {
      map[item.key] = List<String>.from(item.value);
    }
    return Map<String, List<String>>.from(map);
  }

  static Map<String, dynamic> overlay(Map<String, dynamic> defObject, Map<String, dynamic>? overlayObject) {
    if (overlayObject == null || overlayObject.isEmpty || identical(defObject, overlayObject)) {
      return defObject;
    }
    for (MapEntry<String, dynamic> item in overlayObject.entries) {
      defObject[item.key] = item.value;
    }
    return defObject;
  }

  static Uint8List base64Decode(String data) {
    return base64.decode(data);
  }

  static String uuid() {
    return uuidObject.v4();
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static List<String>? castListDynamicToString(dynamic list) {
    return (list as List)?.map((item) => item as String)?.toList();
  }

  static Selector? getSelector(String path, Map data, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<String> exp = path.split(".");
    Selector selector = Selector();
    selector.ref = data;
    selector.parent = data;
    for (String key in exp) {
      dynamic curKey = key;
      if (selector.ref.runtimeType == List) {
        curKey = int.parse(key);
      }
      if (selector.ref != null && selector.ref[curKey] != null) {
        selector.parent = selector.ref;
        selector.ref = selector.ref[curKey];
      }
    }
    try {
      selector.key = exp[exp.length - 1];
      if (selector.parent.runtimeType == List) {
        selector.key = int.parse(selector.key);
      }
      return selector;
    } catch (error, stackTrace) {
      Util.log("Reference.get exp: $exp; selectorReference: $selector; Error: $error",
          stackTrace: stackTrace, type: "error");
    }
    return null;
  }
}

class Selector {
  dynamic parent;
  dynamic key;
  dynamic ref;

  set(dynamic value) {
    parent[key] = value;
  }

  @override
  String toString() {
    return 'Selector{parent: $parent, key: $key, ref: $ref}';
  }
}

enum LoggerMsg {
  Default("0"),
  DefaultBackground("7"),
  Black("30"),
  BlackBackground("40"),
  Red("31"),
  RedBackground("41"),
  Green("32"),
  GreenBackground("42"),
  Yellow("33"),
  YellowBackground("43"),
  Blue("34"),
  BlueBackground("44"),
  Magenta("35"),
  MagentaBackground("45"),
  Cyan("36"),
  CyanBackground("46"),
  Gray("37"),
  GrayBackground("47");

  final String code;

  const LoggerMsg(this.code);

  String wrap(dynamic text) {
    return "\x1B[${code}m$text\x1B[0m";
  }

  static LoggerMsg find(String text) {
    for (LoggerMsg item in LoggerMsg.values) {
      if (item.name == text) {
        return item;
      }
    }
    switch (text) {
      case "javascript":
        return LoggerMsg.Green;
      case "info":
        return LoggerMsg.Yellow;
      case "error":
        return LoggerMsg.Red;
      case "request":
        return LoggerMsg.Green;
      case "response":
        return LoggerMsg.Blue;
      default:
        return LoggerMsg.Default;
    }
  }
}
