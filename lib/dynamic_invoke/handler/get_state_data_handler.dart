import 'package:flutter/foundation.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class GetStateDataHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['key', 'default'])) {
      dynamic value = dynamicUIBuilderContext.dynamicPage
          .getStateData(args['key'], args['default']);
      return {args['key']: value};
    } else {
      if (kDebugMode) {
        print(
            "GetStateDataHandler not contains Keys: [key, default] in args: $args");
      }
    }
  }
}
