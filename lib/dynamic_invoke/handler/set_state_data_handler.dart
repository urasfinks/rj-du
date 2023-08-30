import 'package:flutter/foundation.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';

class SetStateDataHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key", "value"])) {
      dynamicUIBuilderContext.dynamicPage.stateData
          .set(args["state"], args["key"], args["value"], args["notify"] ?? true);
    } else if (Util.containsKeys(args, ["map"])) {
      //Util.log("SetStateDataHandler args: $args");
      dynamicUIBuilderContext.dynamicPage.stateData.setMap(args["state"], args["map"], args["notify"] ?? true);
    } else {
      if (kDebugMode) {
        print("SetStateDataHandler undefined scheme args: $args");
      }
    }
  }
}
