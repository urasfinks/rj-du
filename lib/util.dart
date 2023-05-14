import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'translate.dart';

import 'data_type.dart';
import 'dynamic_ui/type_parser.dart';
import 'package:intl/intl.dart';

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

  static dynamic path2(Map<String, dynamic> data, String path,
      [dynamic defaultValue]) {
    defaultValue ??= "[$path]";
    List<String> exp = path.split(".");
    dynamic cur = data;
    bool find = true;
    for (String key in exp) {
      if (cur != null && cur[key] != null) {
        cur = cur[key];
      } else {
        find = false;
        break;
      }
    }
    if (!find) {
      return defaultValue;
    }
    // if (cur == null) {
    //   return "null";
    // }
    //Наткнулся на проблему, надо вернуть Map что бы потом через дерективу сделать jsonEncode
    return cur;
    //return cur.toString();
    // if (cur.runtimeType.toString() == "bool") {
    //   return cur == true ? "true" : "false";
    // }
    // if (cur.runtimeType.toString() == "String") {
    //   return cur != null ? cur.toString() : "null";
    // }
    // if (defaultValue != "") {
    //   return defaultValue;
    // } else {
    //   String result = "Path: $path is not String";
    //   try {
    //     result = jsonEncode(cur);
    //   } catch (e) {
    //     result += e.toString();
    //   }
    //   return result;
    // }
  }

  static String template(
      String template, DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool autoEscape = true, debug = false]) {
    List<String> exp = template.split('\${');

    for (String expItem in exp) {
      if (!expItem.contains("}")) {
        continue;
      }
      List<String> exp2 = expItem.split("}");
      if (exp2.isEmpty) {
        continue;
      }
      String templateName = exp2[0];
      List<String> expDirective = exp2[0].split("|");
      dynamic value =
          parseTemplateQuery(expDirective.removeAt(0), dynamicUIBuilderContext);
      // if (autoEscape == true && expDirective.isEmpty) {
      //   value = jsonStringEscape(value);
      // }
      if (expDirective.isNotEmpty) {
        for (String directive in expDirective) {
          for (MapEntry<
                  String,
                  dynamic Function(dynamic data, List<String> arguments,
                      DynamicUIBuilderContext dynamicUIBuilderContext)> item
              in templateDirective.entries) {
            if (directive.startsWith("${item.key}(")) {
              List<String> arguments = parseArguments(directive.substring(
                  item.key.length + 1, directive.length - 1));
              value = item.value(value, arguments, dynamicUIBuilderContext);
              break;
            }
          }
        }
      }
      template = template.replaceAll("\${$templateName}", value.toString());
    }
    return template;
  }

  static Map<
          String,
          dynamic Function(dynamic data, List<String> arguments,
              DynamicUIBuilderContext dynamicUIBuilderContext)>
      templateDirective = {
    "escape": (data, arguments, ctx) {
      return data != null ? jsonStringEscape(data) : '';
    },
    "jsonEncode": (data, arguments, ctx) {
      //print("jsonEncode ${data.runtimeType} > ${json.encode(data)}");
      return data != null ? json.encode(data) : '';
    },
    "formatNumber": (data, arguments, ctx) {
      if (data == null || data.toString() == "") {
        return "";
      }
      return NumberFormat(arguments[0]).format(TypeParser.parseDouble(data)!);
    },
    "timestampToDate": (data, arguments, ctx) {
      if (data == null || data.toString() == "") {
        return "";
      }
      int? x = TypeParser.parseInt(data);
      if (x != null) {
        /*if (data.length == 10) {
          x *= 1000;
        }*/
        return DateFormat(arguments[0])
            .format(DateTime.fromMillisecondsSinceEpoch(x));
      }
      return "timestampToDate exception; Data: $data; Args: $arguments";
    }
  };

  static Map<
      String,
      dynamic Function(Map<String, dynamic> data, List<String> arguments,
          DynamicUIBuilderContext dynamicUIBuilderContext)> templateFunction = {
    "context": (data, arguments, ctx) {
      return mapSelector(data, arguments);
    },
    "state": (data, arguments, ctx) {
      return mapSelector(
          getMutableMap(ctx.dynamicPage.stateData.value), arguments);
    },
    "pageArgument": (data, arguments, ctx) {
      return mapSelector(ctx.dynamicPage.arguments, arguments);
    },
    "container": (data, arguments, ctx) {
      return ctx.dynamicPage.templateByContainer(arguments);
    },
    "translate": (data, arguments, ctx) {
      return Translate().getByArgs(arguments);
    },
    "undefined": (data, arguments, ctx) {
      return DynamicUIBuilderContext.template(arguments);
    }
  };

  static dynamic parseTemplateQuery(
      String query, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (!query.contains("(")) {
      query = "context($query)";
    }
    for (MapEntry<
            String,
            dynamic Function(Map<String, dynamic> data, List<String> arguments,
                DynamicUIBuilderContext dynamicUIBuilderContext)> item
        in templateFunction.entries) {
      if (query.startsWith("${item.key}(")) {
        List<String> arguments = parseArguments(
            query.substring(item.key.length + 1, query.length - 1));
        return item.value(
            dynamicUIBuilderContext.data, arguments, dynamicUIBuilderContext);
      }
    }
    return "Undefined handler for: $query";
  }

  static dynamic mapSelector(Map<String, dynamic> data, List<String> args) {
    if (args.length == 1) {
      return path2(data, args[0]);
    } else if (args.length == 2) {
      return path2(data, args[0], args[1]);
    } else {
      return "mapSelector($args) length must be 1|2";
    }
  }

  static List<String> parseArguments(String args) {
    List<String> result = [];
    for (String arg in args.split(',')) {
      result.add(arg.trim());
    }
    return result;
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

  static Map<String, dynamic> getMutableMap(Map map) {
    return json.decode(json.encode(map));
  }
}
