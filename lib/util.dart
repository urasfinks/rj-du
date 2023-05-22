import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/util/template.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';

import 'data_type.dart';

class Util {
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

  static String template(
      String template, DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool autoEscape = true, debug = false]) {
    return Template.template(
        template, dynamicUIBuilderContext, autoEscape, debug);
  }

  static Map<String, dynamic> templateArguments(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Template.templateArguments(args, dynamicUIBuilderContext);
  }

  static void log(dynamic mes) {
    developer.log(mes.toString());
  }

  static String jsonPretty(dynamic object) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
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

  static Map<String, dynamic> merge(
      Map<String, dynamic> def, Map<String, dynamic>? input) {
    if (input == null || input.isEmpty) {
      return def;
    }
    for (var item in input.entries) {
      def[item.key] = item.value;
    }
    return def;
  }

  static String intLPad(int i, {int pad = 0, String char = "0"}) =>
      i.toString().padLeft(pad, char);

  static String intRPad(int i, {int pad = 0, String char = "0"}) =>
      i.toString().padRight(pad, char);

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
    return double.tryParse(s) != null;
  }

  static int getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static Key getKey() {
    return UniqueKey();
  }

  static DataType dataTypeValueOf(String? val) {
    if (val == null) {
      return DataType.any;
    }
    List<DataType> values = DataType.values;
    String find = 'DataType.$val';
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

  static Future<dynamic> asyncInvokeIsolate(
      Function(dynamic arg) fn, dynamic arg) async {
    if (arg != null) {
      return await compute(fn, arg);
    }
  }

  static Future<void> asyncInvoke(
      Function(dynamic args) fn, dynamic args) async {
    Future<void>.delayed(Duration.zero).then((_) {
      fn(args);
    });
  }

  static Map<String, dynamic> getMutableMap(Map? map) {
    return map == null ? {} : json.decode(json.encode(map));
  }
}
