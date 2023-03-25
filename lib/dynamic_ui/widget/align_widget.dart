import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class AlignWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Align(
      key: Util.getKey(),
      alignment: TypeParser.parseAlignment(
        getValue(parsedJson, 'alignment', 'center', dynamicUIBuilderContext),
      )!,
      widthFactor: TypeParser.parseDouble(
        getValue(parsedJson, 'widthFactor', null, dynamicUIBuilderContext),
      ),
      heightFactor: TypeParser.parseDouble(
        getValue(parsedJson, 'heightFactor', null, dynamicUIBuilderContext),
      ),
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
    );
  }
}
