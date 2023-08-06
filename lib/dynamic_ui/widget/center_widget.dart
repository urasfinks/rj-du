import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';

import '../../util.dart';

class CenterWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Center(
      key: Util.getKey(),
      child: render(
        parsedJson,
        "child",
        DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
        dynamicUIBuilderContext,
      ),
    );
  }
}
