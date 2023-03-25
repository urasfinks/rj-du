import 'package:flutter/foundation.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';

class SetStateDataHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['key', 'value'])) {
      dynamicUIBuilderContext.dynamicPage.setStateData(args['key'], args['value']);
    } else {
      if (kDebugMode) {
        print("SetStateDataHandler not contains Keys: [key, value] in args: $args");
      }
    }
  }
}
