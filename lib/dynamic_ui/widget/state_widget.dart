import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import '../dynamic_ui.dart';
import 'abstract_widget.dart';

class StateWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> data = dynamicUIBuilderContext.dynamicPage.stateData.value[parsedJson["key"]] ?? {};
    return render(
      data,
      null,
      DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
      dynamicUIBuilderContext,
    );
  }
}
