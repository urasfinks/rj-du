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
      try {
        if (arguments.isEmpty) {
          return "TemplateDirective.timestampToDate empty argument format";
        }
        if (data.toString().length != 10) {
          return "TemplateDirective.timestampToDate timestamp != 10; Data: $data; Args: $arguments";
        }
        int? x = TypeParser.parseInt(data);
        if (x == null) {
          return "TemplateDirective.timestampToDate parse int exception; Data: $data; Args: $arguments";
        }
        return DateFormat(arguments[0]).format(DateTime.fromMillisecondsSinceEpoch(x * 1000));
      } catch (error, stackTrace) {
        Util.log("TemplateDirective.timestampToDate($data, $arguments); Error: $error", stackTrace: stackTrace, type: "error");
        return "TemplateDirective.timestampToDate exception: $error; Data: $data; Args: $arguments";
      }
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
    "capitalize": (data, arguments, ctx) {
      return Util.capitalize(data);
    },
    "lPad": (data, arguments, ctx) {
      int pad = TypeParser.parseInt(Util.listGet(arguments, 0, "0")) ?? 0;
      String char = Util.listGet(arguments, 1, "0") ?? "";
      return Util.lPad(data, pad: pad, char: char);
    },
    "rPad": (data, arguments, ctx) {
      int pad = TypeParser.parseInt(Util.listGet(arguments, 0, "0")) ?? 0;
      String char = Util.listGet(arguments, 1, "0") ?? "";
      return Util.rPad(data, pad: pad, char: char);
    },
    "timeSoFar": (data, arguments, ctx) {
      if (data == null || data == "") {
        return "неизвестно";
      }
      int curTimestamp = Util.getTimestamp();
      int d = Util.getTimestamp();
      try {
        d = TypeParser.parseInt(data)!;
      } catch (error, stackTrace) {
        Util.log("TemplateDirective.timeSoFar($data, $arguments); Error: $error", stackTrace: stackTrace, type: "error");
      }

      int diffSec = curTimestamp - d;
      int diffDays = (diffSec / 86400).floor();
      if (diffDays > 0) {
        return "$diffDaysд.";
      }
      int diffHrs = ((diffSec % 86400) / 3600).floor();
      if (diffHrs > 0) {
        return "$diffHrsч.";
      }
      int diffMins = (((diffSec % 86400) % 3600) / 60).floor();
      if (diffMins > 0) {
        return "$diffMinsмин.";
      }
      int diffSeconds = ((diffSec % 86400) % 3600).floor();
      if (diffSeconds > 0) {
        return "$diffSecondsсек.";
      }
      return "сейчас";
    },
    "map": (data, arguments, ctx) {
      dynamic result = data;
      if (arguments.length % 2 != 0) {
        //Если кол-во не чётное значит есть значение по умолчанию
        result = arguments.last;
        arguments.removeLast();
      }
      for (int i = 0; i < arguments.length; i += 2) {
        if (arguments[i] == data.toString()) {
          return arguments[i + 1];
        }
      }
      return result;
    },
    "ifNotExist": (data, arguments, ctx) {
      if (data == null || data.toString().trim() == "") {
        return Util.listGet(arguments, 0, "");
      }
      return data;
    },
    "template": (data, arguments, ctx) {
      return Util.template(data, ctx);
    }
  };

  static dynamic invoke(
      String fn, dynamic data, List<String> arguments, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (map.containsKey(fn)) {
      return map[fn]!(data, arguments, dynamicUIBuilderContext);
    }
    return data;
  }
}
