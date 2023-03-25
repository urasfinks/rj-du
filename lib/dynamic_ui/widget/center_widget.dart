import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/widget/size_box_widget.dart';
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
        'child',
        SizedBoxWidget().get(parsedJson, dynamicUIBuilderContext),
        dynamicUIBuilderContext,
      ),
    );
  }
}
