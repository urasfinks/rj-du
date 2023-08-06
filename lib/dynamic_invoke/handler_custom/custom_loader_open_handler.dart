import 'package:rjdu/dynamic_invoke/dynamic_invoke.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/navigator_push_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

class CustomLoaderOpenHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    DynamicInvoke().sysInvokeType(
        NavigatorPushHandler,
        {
          "name": "CustomLoader",
          "type": "Dialog",
          "link": {
            "template": "_Loader.json",
          },
          "linkDefault": {
            "template": {
              "flutterType": "Material",
              "type": "transparency",
              "child": {
                "flutterType": "Center",
                "child": {
                  "flutterType": "CircularProgressIndicator",
                  "backgroundColor": "schema:background",
                  "color": "schema:secondary"
                }
              }
            }
          }
        },
        dynamicUIBuilderContext);
  }
}
