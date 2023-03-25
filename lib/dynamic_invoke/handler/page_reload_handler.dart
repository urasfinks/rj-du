import 'package:flutter/foundation.dart';
import '../../navigator_app.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

import '../../util.dart';

class PageReloadHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key", "value"])) {
      NavigatorApp.reloadPage(args["key"], args["value"]);
    } else {
      if (kDebugMode) {
        print("PageReloadHandler not contains keys: [key, value] in args: $args");
      }
    }
  }
}
