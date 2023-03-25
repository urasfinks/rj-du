import 'package:rjdu/dynamic_ui/widget/size_box_widget.dart';

import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class PaddingWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Padding(
      key: Util.getKey(),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, 'padding', null, dynamicUIBuilderContext),
      )!,
      child: render(
        parsedJson,
        'child',
        SizedBoxWidget().get(parsedJson, dynamicUIBuilderContext),
        dynamicUIBuilderContext,
      ),
    );
  }
}
