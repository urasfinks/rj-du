import 'package:rjdu/util/template/Parser/new_template.dart';
import 'package:rjdu/util/template/Parser/template_item.dart';
import 'package:rjdu/util/template/directive.dart';
import 'package:rjdu/util/template/function.dart';

import '../dynamic_ui/dynamic_ui_builder_context.dart';
import '../util.dart';

class Template {
  static List<TemplateItem> getRegisteredListTemplateItem(String template, DynamicUIBuilderContext dynamicUIBuilderContext) {
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
        for (MapEntry<String,
                dynamic Function(dynamic data, List<String> arguments, DynamicUIBuilderContext dynamicUIBuilderContext)> item
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
        dynamic Function(Map<String, dynamic> data, List<String> arguments, DynamicUIBuilderContext dynamicUIBuilderContext,
            bool debug)> item in TemplateFunction.map.entries) {
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
      Util.printStackTrace("Template.stringSelector() path: $path; defaultValue: $defaultValue; data: $data", e, stacktrace);
      find = false;
    }
    if (!find) {
      return defaultValue;
    }
    return cur;
  }

  static void compileTemplateList(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String key = "compileTemplateList";
    if (parsedJson.containsKey(key)) {
      for (String query in parsedJson[key]) {
        Selector? selector = Util.getSelector(query, parsedJson, dynamicUIBuilderContext);
        if (selector != null) {
          if (selector.ref.runtimeType == String) {
            selector.set(template(selector.ref, dynamicUIBuilderContext));
          } else {
            Util.printCurrentStack("Template.compileTemplateList() ref must be String, real: ${selector.ref}");
          }
        }
      }
    }
  }
}
