import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import '../../util.dart';
import '../../storage.dart';

class SetStorageHandler extends AbstractHandler{
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['key', 'value'])) {
      Storage().set(args['key'], args['value'], args['updateIfExist'] ?? true);
    } else {
      if (kDebugMode) {
        print("SetStorageHandler not contains Keys: [key, value] in args: $args");
      }
    }
  }

}