import 'package:flutter/foundation.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.containsKey("url") && args["url"] != "") {
      launch(args["url"], forceSafariVC: false);
    } else {
      if (kDebugMode) {
        print("UrlLauncherHandler.handle() Url is empty");
      }
    }
  }
}
