import 'package:flutter_share/flutter_share.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';

class ShareHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    FlutterShare.share(title: "Поделиться", text: args["data"]);
  }
}
