import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';

class NotifyWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> def = parsedJson['linkDefault'] == null ? {} : parsedJson['linkDefault'] as Map<String, dynamic>;
    DynamicUIBuilderContext newContext = dynamicUIBuilderContext.cloneWithNewData(def);

    if (parsedJson.containsKey('linkContainer')) {
      dynamicUIBuilderContext.dynamicPage.setContainer(parsedJson['linkContainer'], newContext);
    }
    return newContext.dynamicPage.dynamicPageNotifier.notifyWidget(
      parsedJson['link'],
      newContext,
      (context, child) {
        if (!newContext.data.containsKey('template')) {
          if (kDebugMode) {
            print("NotifyWidget.build() key template not exist; data: ${newContext.data}");
          }
          return Text("NotifyWidget.getWidget() key template not exist; data: ${newContext.data}");
        }
        dynamic resultWidget = render(newContext.data['template'], null, const SizedBox(), newContext);
        if (resultWidget != null && resultWidget.runtimeType.toString().contains('Map<String,')) {
          if (kDebugMode) {
            print(
                "NotifyWidget.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; input: $parsedJson; Must be Widget");
          }
          return Text("NotifyWidget.build() Return: $resultWidget; type: ${resultWidget.runtimeType}; Must be Widget");
        }
        return resultWidget;
      },
    );
  }
}
