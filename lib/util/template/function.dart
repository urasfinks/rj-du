import 'package:rjdu/global_settings.dart';
import 'package:rjdu/storage.dart';
import 'package:rjdu/util.dart';
import 'package:rjdu/util/template.dart';

import '../../db/data.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../translate.dart';

class TemplateFunction {
  static Map<
      String,
      dynamic Function(Map<String, dynamic> data, List<String> arguments,
          DynamicUIBuilderContext dynamicUIBuilderContext, bool debug)> map = {
    "context": (data, arguments, ctx, debug) {
      return Template.mapSelector(data, arguments);
    },
    "contextMap": (data, arguments, ctx, debug) {
      return ctx.dynamicPage.templateByMapContext(data, arguments);
    },
    "contextKey": (data, arguments, ctx, debug) {
      return ctx.key;
    },
    "state": (data, arguments, ctx, debug) {
      Data d = ctx.dynamicPage.stateData.getInstanceData(arguments.removeAt(0));
      dynamic result = Template.mapSelector(d.value, arguments);
      if (debug) {
        Util.p("TemplateFunction.state() arguments: $arguments => $result");
      }
      return result;
    },
    "stateUuid": (data, arguments, ctx, debug) {
      Data d = ctx.dynamicPage.stateData.getInstanceData(arguments.isNotEmpty ? arguments.first : null);
      return d.uuid;
    },
    "pageArgs": (data, arguments, ctx, debug) {
      return Template.mapSelector(ctx.dynamicPage.arguments, arguments);
    },
    "translate": (data, arguments, ctx, debug) {
      return Translate().get(arguments);
    },
    "undefined": (data, arguments, ctx, debug) {
      return DynamicUIBuilderContext.template(arguments);
    },
    "storage": (data, arguments, ctx, debug) {
      if (arguments.length == 1) {
        return Storage().getByTemplate(arguments[0], "[${arguments[0]}]");
      } else if (arguments.length == 2) {
        return Storage().getByTemplate(arguments[0], arguments[1]);
      } else {
        return "storage($arguments) length must be 1|2";
      }
    },
    "timestamp": (data, arguments, ctx, debug) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    },
    "keysState": (data, arguments, ctx, debug) {
      return ctx.dynamicPage.stateData.map.keys.join(",");
    },
    "globalSettings": (data, arguments, ctx, debug) {
      return GlobalSettings().template(arguments[0], arguments[1]);
    }
  };
}
