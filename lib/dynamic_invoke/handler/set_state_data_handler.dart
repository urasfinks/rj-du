import 'package:flutter/foundation.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';

class SetStateDataHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key", "value"])) {
      dynamicUIBuilderContext.dynamicPage.setStateData(args["key"], args["value"], args["notify"] ?? true);
    } else if (Util.containsKeys(args, ["map"])) {
      dynamicUIBuilderContext.dynamicPage.setStateDataMap(args["map"], args["notify"] ?? true);
    } else {
      if (kDebugMode) {
        print("SetStateDataHandler undefined scheme args: $args");
      }
    }
  }
}
