import 'package:flutter/foundation.dart';
import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

import '../../util.dart';

class PageReloadHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.isEmpty) {
      dynamicUIBuilderContext.dynamicPage.reload();
    } else if (Util.containsKeys(args, ["key", "value"])) {
      NavigatorApp.reloadPageByArguments(args["key"], args["value"]);
    } else {
      if (kDebugMode) {
        print("PageReloadHandler WTF?");
      }
    }
  }
}
