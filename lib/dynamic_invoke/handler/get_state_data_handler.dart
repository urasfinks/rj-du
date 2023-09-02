import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class GetStateDataHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key", "default"])) {
      dynamic value = dynamicUIBuilderContext.dynamicPage.stateData.get(args["state"], args["key"], args["default"]);
      return {args["key"]: value};
    } else {
      Util.p("GetStateDataHandler not contains Keys: [key, default] in args: $args");
    }
  }
}
