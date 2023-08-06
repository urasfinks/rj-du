import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';

class NotifyWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> def =
        parsedJson["linkDefault"] == null ? {} : parsedJson["linkDefault"] as Map<String, dynamic>;
    DynamicUIBuilderContext newContext =
        dynamicUIBuilderContext.cloneWithNewData(def, parsedJson["linkContainer"] ?? "Notify");

    if (parsedJson.containsKey("linkContainer") && parsedJson["linkContainer"] != null) {
      dynamicUIBuilderContext.dynamicPage.setContainer(parsedJson["linkContainer"], newContext);
    }
    Map<String, dynamic> link = parsedJson["link"];
    for (String uuidLink in link.keys) {
      newContext.addListener(uuidLink);
    }
    return newContext.dynamicPage.storeValueNotifier.getWidget(
      parsedJson["link"],
      newContext,
      (context, child) {
        if (parsedJson.containsKey("template")) {
          return checkNullWidget(
            "NotifyWidget",
            parsedJson,
            render(parsedJson["template"], null, const SizedBox(), newContext),
          );
        }
        if (newContext.data.containsKey("template")) {
          return checkNullWidget(
            "NotifyWidget",
            parsedJson,
            render(newContext.data["template"], null, const SizedBox(), newContext),
          );
        }
        if (kDebugMode) {
          print("NotifyWidget.build() key template not exist; data: ${newContext.data}");
        }
        return Text("NotifyWidget.getWidget() key template not exist; data: ${newContext.data}");
      },
    );
  }
}
