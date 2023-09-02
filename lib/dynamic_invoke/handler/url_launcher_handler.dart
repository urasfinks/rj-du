import '../../util.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (args.containsKey("url") && args["url"] != "") {
      launch(args["url"], forceSafariVC: false);
    } else {
      Util.p("UrlLauncherHandler.handle() Url is empty");
    }
  }
}
