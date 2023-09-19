import 'package:flutter/cupertino.dart';
import '../../util.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';

class NotifyWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    dynamicUIBuilderContext.linkedNotify = parsedJson["link"];
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
        Util.p("NotifyWidget.build() key template not exist; parsedJson: $parsedJson; data: ${dynamicUIBuilderContext.data}");
        return Text("NotifyWidget.getWidget() key template not exist; data: ${dynamicUIBuilderContext.data}");
      },
    );
  }
}
