import 'package:rjdu/storage.dart';
import 'package:rjdu/util/template.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../translate.dart';
import '../../util.dart';

class TemplateFunction {
  static Map<
      String,
      dynamic Function(Map<String, dynamic> data, List<String> arguments,
          DynamicUIBuilderContext dynamicUIBuilderContext)> map = {
    "context": (data, arguments, ctx) {
      return Template.mapSelector(data, arguments);
    },
    "state": (data, arguments, ctx) {
      return Template.mapSelector(
          Util.getMutableMap(ctx.dynamicPage.stateData.value), arguments);
    },
    "pageArgument": (data, arguments, ctx) {
      return Template.mapSelector(ctx.dynamicPage.arguments, arguments);
    },
    "container": (data, arguments, ctx) {
      return ctx.dynamicPage.templateByContainer(arguments);
    },
    "translate": (data, arguments, ctx) {
      return Translate().getByArgs(arguments);
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
    }
  };
}
