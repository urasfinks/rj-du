import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import '../../util.dart';

class SubscribeRefreshHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["uuid"])) {
      //print("SubscribeRefresh uuid: ${args["uuid"]}");
      if (!dynamicUIBuilderContext.dynamicPage.listUpdateUuidToReloadDynamicPage.contains(args["uuid"])) {
        dynamicUIBuilderContext.dynamicPage.listUpdateUuidToReloadDynamicPage.add(args["uuid"]);
      }
    } else {
      if (kDebugMode) {
        print("SubscribeRefresh not contains Keys: [uuid] in args: $args");
      }
    }
  }
}
