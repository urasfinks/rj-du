import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class SizedBoxBottomNavigationBarWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    double extraBottomOffset = TypeParser.parseDouble(
      getValue(parsedJson, 'extraBottomOffset', 0, dynamicUIBuilderContext),
    )!;
    return SizedBox(
      key: Util.getKey(),
      width: TypeParser.parseDouble(
        getValue(parsedJson, 'width', null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        GlobalSettings().bottomNavigationBarHeight + extraBottomOffset,
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}
