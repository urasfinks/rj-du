import 'package:flutter/foundation.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';
import 'abstract_handler.dart';
import '../../storage.dart';

class GetStorageHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key", "default"])) {
      return {args["key"]: Storage().get(args["key"], args["default"])};
    } else {
      if (kDebugMode) {
        print("GetStorageHandler not contains Keys: [key, default] in args: $args");
      }
    }
  }
}