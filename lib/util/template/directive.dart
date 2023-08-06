import 'dart:convert';

import 'package:intl/intl.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../dynamic_ui/type_parser.dart';
import '../../util.dart';

class TemplateDirective {
  static Map<String,
      dynamic Function(dynamic data, List<String> arguments, DynamicUIBuilderContext dynamicUIBuilderContext)> map = {
    "escape": (data, arguments, ctx) {
      return data != null ? Util.jsonStringEscape(data) : "";
    },
    "jsonEncode": (data, arguments, ctx) {
      //print("TemplateDirective.jsonEncode ${data.runtimeType} > ${json.encode(data)}");
      return data != null ? json.encode(data) : "";
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
        return DateFormat(arguments[0]).format(DateTime.fromMillisecondsSinceEpoch(x));
      }
      return "timestampToDate exception; Data: $data; Args: $arguments";
    },
    "partHideEmail": (data, arguments, ctx) {
      String email = data.toString();
      int indexOf = email.indexOf("@");
      String result = "";
      if (indexOf > 2) {
        result = email.substring(0, 1);
        for (int i = 0; i < indexOf - 2; i++) {
          result += "*";
        }
        result += email.substring(indexOf - 1);
      } else if (indexOf >= 0 && email.length >= 6) {
        result = email.substring(0, indexOf + 2);
        for (int i = 0; i < email.length - result.length; i++) {
          result += "*";
        }
        result += email.substring(email.length - 1);
      } else if (email.length >= 3) {
        result = email.substring(0, 1);
        for (int i = 0; i < email.length - 2; i++) {
          result += "*";
        }
        result += email.substring(email.length - 1, email.length);
      } else {
        result = "*";
      }
      return result;
    },
    "map": (data, arguments, ctx) {
      for (int i = 0; i < arguments.length; i += 2) {
        if (arguments[i] == data) {
          return arguments[i + 1];
        }
      }
      return data;
    }
  };
}
