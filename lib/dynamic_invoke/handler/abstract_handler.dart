import 'package:rjdu/dynamic_invoke/dynamic_invoke.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';

abstract class AbstractHandler {
  dynamic handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext);

  String getName() {
    return runtimeType.toString().replaceAll("Handler", "");
  }

  AbstractHandler() {
    DynamicInvoke().handler[getName()] = handle;
  }
}
