import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';

class NotifyWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> link = parsedJson["link"];
    for (String uuidLink in link.keys) {
      dynamicUIBuilderContext.addListener(uuidLink);
    }
    return dynamicUIBuilderContext.dynamicPage.storeValueNotifier.getWidget(
      parsedJson["link"],
      dynamicUIBuilderContext,
      (context, child) {
        if (parsedJson.containsKey("template")) {
          return checkNullWidget(
            "NotifyWidget",
            parsedJson,
            render(parsedJson["template"], null, const SizedBox(), dynamicUIBuilderContext),
          );
        }
        if (dynamicUIBuilderContext.data.containsKey("template")) {
          return checkNullWidget(
            "NotifyWidget",
            parsedJson,
            render(dynamicUIBuilderContext.data["template"], null, const SizedBox(), dynamicUIBuilderContext),
          );
        }
        if (kDebugMode) {
          print("NotifyWidget.build() key template not exist; data: ${dynamicUIBuilderContext.data}");
        }
        return Text("NotifyWidget.getWidget() key template not exist; data: ${dynamicUIBuilderContext.data}");
      },
    );
  }
}
