import '../../controller_wrap.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';

class ControllerHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["key"])) {
      String key = args["key"];
      if (dynamicUIBuilderContext.dynamicPage.isProperty(key)) {
        ControllerWrap tec = dynamicUIBuilderContext.dynamicPage.getPropertyFn(key, () {
          return null;
        });
        tec.invoke(args, dynamicUIBuilderContext);
      }
    } else {
      Util.printCurrentStack("ControllerHandler not contains Keys: [key] in args: $args");
    }
  }
}
