import 'package:rjdu/dynamic_invoke/dynamic_invoke.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/navigator_push_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

class CustomLoaderOpenHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    DynamicInvoke().sysInvokeType(
        NavigatorPushHandler,
        {
          "name": "CustomLoader",
          "type": "dialog",
          "barrierColorOpacity": 0.4,
          "link": {
            "template": "_Loader.json_this_is_not_exist",
          },
          "context": {
            "key": "CustomLoaderOpenHandler",
            "data": {
              "template": {
                "flutterType": "Material",
                "type": "transparency",
                "child": {
                  "flutterType": "Center",
                  "child": {
                    "flutterType": "Container",
                    "width": 55,
                    "height": 55,
                    "child": {
                      "flutterType": "Stack",
                      "fit": "expand",
                      "alignment": "center",
                      "children": [
                        {
                          "flutterType": "CircularProgressIndicator",
                          "backgroundColor": "schema:background",
                          "color": "schema:secondary"
                        },
                        {
                          "flutterType": "Center",
                          "child": {
                            "flutterType": "Stream",
                            "controller": "loader",
                            "stream": {
                              "data": {"prc": 0}
                            },
                            "child": {
                              "flutterType": "Text",
                              "label": "\${prc|map(0,)}\${prc|map(0,,%)}",
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              }
            }
          }
        },
        dynamicUIBuilderContext);
  }
}
