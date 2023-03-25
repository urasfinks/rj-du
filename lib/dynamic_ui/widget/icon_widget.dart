import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';
import '../icon.dart';

class IconWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Icon(
      iconsMap[getValue(parsedJson, 'src', null, dynamicUIBuilderContext)],
      key: Util.getKey(),
      color: TypeParser.parseColor(
        getValue(parsedJson, 'color', null, dynamicUIBuilderContext),
      ),
      size: TypeParser.parseDouble(
        getValue(parsedJson, 'size', null, dynamicUIBuilderContext),
      ),
    );
  }
}
