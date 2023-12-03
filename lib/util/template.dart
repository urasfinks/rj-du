import 'package:rjdu/util/template/Parser/new_template.dart';
import 'package:rjdu/util/template/Parser/template_item.dart';
import 'package:rjdu/util/template/directive.dart';
import 'package:rjdu/util/template/function.dart';

import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../util.dart';

class Template {
  static List<TemplateItem> getRegisteredListTemplateItem(
      String template, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (!dynamicUIBuilderContext.dynamicPage.cacheTemplate.containsKey(template)) {
      dynamicUIBuilderContext.dynamicPage.cacheTemplate[template] = NewTemplate.getParsedTemplate(template);
    }
    return dynamicUIBuilderContext.dynamicPage.cacheTemplate[template]!;
  }

  static String template(String template, DynamicUIBuilderContext dynamicUIBuilderContext,
      [bool autoEscape = true, debug = false]) {
    if (!template.contains("\${")) {
      return template;
    }
    if (!dynamicUIBuilderContext.dynamicPage.cacheTemplate.containsKey(template)) {
      dynamicUIBuilderContext.dynamicPage.cacheTemplate[template] = NewTemplate.getParsedTemplate(template);
    }
    List<TemplateItem> parsedTemplate = getRegisteredListTemplateItem(template, dynamicUIBuilderContext);
    return NewTemplate.templateCallback(
        parsedTemplate, (templateValue) => evolute(templateValue, dynamicUIBuilderContext, debug));
  }

  static String evolute(String templateValue, DynamicUIBuilderContext dynamicUIBuilderContext, bool debug) {
    if (templateValue.contains("\$")) {
      templateValue = template(templateValue, dynamicUIBuilderContext);
    }
    List<String> expDirective = templateValue.split("|");
    dynamic value = parseTemplateQuery(expDirective.removeAt(0), dynamicUIBuilderContext, debug);
    if (expDirective.isNotEmpty) {
      for (String directive in expDirective) {
        for (MapEntry<
                String,
                dynamic Function(
                    dynamic data, List<String> arguments, DynamicUIBuilderContext dynamicUIBuilderContext)> item
            in TemplateDirective.map.entries) {
          if (directive.startsWith("${item.key}(")) {
            // отрезаем имя директивы + скобки
            String directiveValue = directive.substring(item.key.length + 1, directive.length - 1);
            List<String> arguments = parseArguments(directiveValue);
            value = item.value(value, arguments, dynamicUIBuilderContext);
            break;
          }
        }
      }
    }
    return value.toString();
  }

  static dynamic parseTemplateQuery(String query, DynamicUIBuilderContext dynamicUIBuilderContext, bool debug) {
    if (!query.contains("(")) {
      query = "context($query)";
    }
    for (MapEntry<
        String,
        dynamic Function(Map<String, dynamic> data, List<String> arguments,
            DynamicUIBuilderContext dynamicUIBuilderContext, bool debug)> item in TemplateFunction.map.entries) {
      if (query.startsWith("${item.key}(")) {
        List<String> arguments = parseArguments(query.substring(item.key.length + 1, query.length - 1));
        return item.value(dynamicUIBuilderContext.data, arguments, dynamicUIBuilderContext, debug);
      }
    }
    return "Undefined handler for: $query";
  }

  static List<String> parseArguments(String args) {
    List<String> result = [];
    for (String arg in args.split(",")) {
      result.add(arg.trim());
    }
    return result;
  }

  static dynamic mapSelector(Map<String, dynamic> data, List<String> args) {
    if (args.length == 1) {
      return stringSelector(data, args[0]);
    } else if (args.length == 2) {
      return stringSelector(data, args[0], args[1]);
    } else {
      return "mapSelector($args) length must be 1|2";
    }
  }

  static dynamic stringSelector(Map<String, dynamic> data, String path, [dynamic defaultValue]) {
    defaultValue ??= "[$path]";
    bool find = true;
    if (path == ".") {
      Util.log(Util.jsonPretty(data));
      return data;
    }
    dynamic cur = data;
    try {
      List<String> exp = path.split(".");
      for (String key in exp) {
        if (cur != null && cur[key] != null) {
          cur = cur[key];
        } else {
          find = false;
          break;
        }
      }
    } catch (e, stacktrace) {
      Util.printStackTrace(
          "Template.stringSelector() path: $path; defaultValue: $defaultValue; data: $data", e, stacktrace);
      find = false;
    }
    if (!find) {
      return defaultValue;
    }
    return cur;
  }

  static Map<String, dynamic> templateArguments(
      Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.containsKey("templateArguments")) {
      Map<String, dynamic> newArgs = {};
      newArgs.addAll(args);
      for (String query in newArgs["templateArguments"]) {
        tmp(query, newArgs, dynamicUIBuilderContext);
      }
      return newArgs;
    }
    return args;
  }

  static void tmp(String path, Map data, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<String> exp = path.split(".");
    dynamic cur = data;
    dynamic curParent = data;
    for (String key in exp) {
      if (cur != null && cur[key] != null) {
        curParent = cur;
        cur = cur[key];
      }
    }
    curParent[exp[exp.length - 1]] = template(cur, dynamicUIBuilderContext);
  }
}
