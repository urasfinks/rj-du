import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/system_notify.dart';

import '../../util.dart';
import 'abstract_handler.dart';

class SystemNotifyHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ['SystemNotifyEnum', 'state'])) {
      SystemNotifyEnum? enumFromString = Util.enumFromString(SystemNotifyEnum.values, args["SystemNotifyEnum"]);
      if (enumFromString != null) {
        SystemNotify().emit(enumFromString, args["state"]);
      } else {
        if (kDebugMode) {
          print("SystemNotifyHandler SystemNotifyEnum.valueOf('${args["SystemNotifyEnum"]}') return null value;");
        }
      }
    } else {
      if (kDebugMode) {
        print("SystemNotifyHandler not contains Keys: [SystemNotifyEnum, state] in args: $args");
      }
    }
  }
}
