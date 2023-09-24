import '../../controller_wrap.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../util.dart';

class ControllerHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["controller"])) {
      String key = args["controller"];
      if (dynamicUIBuilderContext.dynamicPage.isProperty(key)) {
        ControllerWrap? controllerWrap = dynamicUIBuilderContext.dynamicPage.getPropertyFn(key, () {
          return null;
        });
        if (controllerWrap != null) {
          controllerWrap.invoke(args, dynamicUIBuilderContext);
        } else {
          Util.printCurrentStack("ControllerHandler.handle() ControllerWrap is null args: $args");
        }
      }
    } else {
      Util.printCurrentStack("ControllerHandler not contains Keys: [key] in args: $args");
    }
  }
}
