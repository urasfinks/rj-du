import 'dart:convert';

import 'package:intl/intl.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../dynamic_ui/type_parser.dart';
import '../../util.dart';

class TemplateDirective {
  static Map<
      String,
      dynamic Function(dynamic data, List<String> arguments,
          DynamicUIBuilderContext dynamicUIBuilderContext)> map = {
    "escape": (data, arguments, ctx) {
      return data != null ? Util.jsonStringEscape(data) : '';
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
}
