import 'package:rjdu/global_settings.dart';
import 'package:rjdu/storage.dart';
import 'package:rjdu/util/template.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../translate.dart';

class TemplateFunction {
  static Map<
      String,
      dynamic Function(
          Map<String, dynamic> data, List<String> arguments, DynamicUIBuilderContext dynamicUIBuilderContext)> map = {
    "context": (data, arguments, ctx) {
      return Template.mapSelector(data, arguments);
    },
    "contextByKey": (data, arguments, ctx) {
      return ctx.dynamicPage.templateByMapContext(data, arguments);
    },
    "parentTemplate": (data, arguments, ctx) {
      return Template.mapSelector(ctx.parentTemplate, arguments);
    },
    "getStateUuid": (data, arguments, ctx) {
      return ctx.dynamicPage.stateData.uuid;
    },
    "state": (data, arguments, ctx) {
      // Ранее stateData.value оборачивалось через MutableMap
      // Я убрал, так как ломалось зацикливание для FlipCard
      return Template.mapSelector(ctx.dynamicPage.stateData.value, arguments);
    },
    "pageArgs": (data, arguments, ctx) {
      return Template.mapSelector(ctx.dynamicPage.arguments, arguments);
    },
    "translate": (data, arguments, ctx) {
      return Translate().get(arguments);
    },
    "undefined": (data, arguments, ctx) {
      return DynamicUIBuilderContext.template(arguments);
    },
    "storage": (data, arguments, ctx) {
      if (arguments.length == 1) {
        return Storage().getByTemplate(arguments[0], "[${arguments[0]}]");
      } else if (arguments.length == 2) {
        return Storage().getByTemplate(arguments[0], arguments[1]);
      } else {
        return "storage($arguments) length must be 1|2";
      }
    },
    "timestamp": (data, arguments, ctx) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    },
    "globalSettings": (data, arguments, ctx) {
      return GlobalSettings().template(arguments[0], arguments[1]);
    }
  };
}
