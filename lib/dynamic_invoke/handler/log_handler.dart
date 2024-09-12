import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/util.dart';

class LogHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    args = Util.getMutableMap(args);
    String pageUuid = args["pageUuid"];
    args.removeWhere((key, value) => key == "pageUuid");
    Util.log(
      Util.jsonPretty(args),
      type: args["type"] ?? "javascript",
      correlation: pageUuid,
    );
  }
}
