import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class SizedBoxAppBarWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    double extraTopOffset = TypeParser.parseDouble(
      getValue(parsedJson, 'extraTopOffset', 0, dynamicUIBuilderContext),
    )!;
    return SizedBox(
      key: Util.getKey(),
      width: TypeParser.parseDouble(
        getValue(parsedJson, 'width', null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        GlobalSettings().appBarHeight + extraTopOffset,
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}
