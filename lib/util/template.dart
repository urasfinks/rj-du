import 'package:rjdu/util/template/directive.dart';
import 'package:rjdu/util/template/function.dart';

import '../dynamic_ui/dynamic_ui_builder_context.dart';

class Template {
  static dynamic mapSelector(Map<String, dynamic> data, List<String> args) {
    if (args.length == 1) {
      return stringSelector(data, args[0]);
    } else if (args.length == 2) {
      return stringSelector(data, args[0], args[1]);
    } else {
      return "mapSelector($args) length must be 1|2";
    }
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
          in TemplateDirective.map.entries) {
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

  static dynamic parseTemplateQuery(
      String query, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (!query.contains("(")) {
      query = "context($query)";
    }
    for (MapEntry<
        String,
        dynamic Function(Map<String, dynamic> data, List<String> arguments,
            DynamicUIBuilderContext dynamicUIBuilderContext)> item
    in TemplateFunction.map.entries) {
      if (query.startsWith("${item.key}(")) {
        List<String> arguments = parseArguments(
            query.substring(item.key.length + 1, query.length - 1));
        return item.value(
            dynamicUIBuilderContext.data, arguments, dynamicUIBuilderContext);
      }
    }
    return "Undefined handler for: $query";
  }

  static List<String> parseArguments(String args) {
    List<String> result = [];
    for (String arg in args.split(',')) {
      result.add(arg.trim());
    }
    return result;
  }

  static dynamic stringSelector(Map<String, dynamic> data, String path,
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
}