import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/type_parser.dart';
import 'package:wakelock/wakelock.dart';

import 'abstract_handler.dart';

class WakeLockHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (TypeParser.parseBool(args["lock"]) ?? false) {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }
  }
}
