import 'package:flutter/services.dart';

import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../dynamic_invoke.dart';
import 'abstract_handler.dart';

class CopyClipboardHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Clipboard.setData(ClipboardData(text: args["data"]));
    DynamicInvoke().sysInvoke('Alert', {"label": "Скопировано в буфер обмена"}, dynamicUIBuilderContext);
  }
}
