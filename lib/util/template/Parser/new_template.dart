import 'package:rjdu/util/template/Parser/parser.dart';
import 'package:rjdu/util/template/Parser/template_item.dart';

class NewTemplate {
  static String templateCallback(List<TemplateItem> parsedTemplate, Function(String templateValue) callback) {
    StringBuffer sb = StringBuffer();
    for (TemplateItem templateItem in parsedTemplate) {
      if (templateItem.isStatic()) {
        sb.write(templateItem.getValue());
      } else {
        sb.write(callback(templateItem.getValue()));
      }
    }
    return sb.toString();
  }

  static List<TemplateItem> getParsedTemplate(String template) {
    if (!template.contains("\${")) {
      return [TemplateItem(true, template)];
    }
    Parser parser = Parser();
    List<TemplateItem> result = [];
    for (int i = 0; i < template.length; i++) {
      String ch = template.substring(i, i + 1);
      parser.read(ch);
      if (parser.isTerminal()) {
        String flush = parser.flush();
        if (flush != "") {
          result.add(TemplateItem(true, flush));
        }
      } else if (parser.isFinish()) {
        String flush = parser.flush();
        if (flush != "") {
          result.add(TemplateItem(false, flush));
        }
      }
    }
    String flush = parser.flush();
    if (flush != "") {
      result.add(TemplateItem(true, flush));
    } else if (parser.isParse()) {
      result.add(TemplateItem(true, "\$"));
    }
    return merge(result);
  }

  static String templateParsed(List<TemplateItem> parsedTemplate, Map<String, String> args) {
    StringBuffer sb = StringBuffer();
    for (TemplateItem templateItem in parsedTemplate) {
      if (templateItem.isStatic()) {
        sb.write(templateItem.getValue());
      } else {
        sb.write(args[templateItem.getValue()]);
      }
    }
    return sb.toString();
  }

  static String templateString(String template, Map<String, String> args) {
    return templateParsed(getParsedTemplate(template), args);
  }

  static List<TemplateItem> merge(List<TemplateItem> input) {
    List<TemplateItem> result = [];
    int index = 0;
    List<TemplateItem> tmp = [];
    while (true) {
      if (index > input.length - 1) {
        get(tmp, result);
        break;
      }
      TemplateItem templateItem = input[index++];
      if (!templateItem.isStatic()) {
        get(tmp, result);
        tmp.clear();
        result.add(templateItem);
      } else {
        tmp.add(templateItem);
      }
    }
    return result;
  }

  static void get(List<TemplateItem> tmp, List<TemplateItem> result) {
    if (tmp.isNotEmpty) {
      StringBuffer sb = StringBuffer();
      for (TemplateItem item in tmp) {
        sb.write(item.getValue());
      }
      result.add(TemplateItem(true, sb.toString()));
    }
  }
}
