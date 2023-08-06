import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class CircleAvatarWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return CircleAvatar(
      key: Util.getKey(),
      backgroundImage: getValue(parsedJson, "backgroundImage", null, dynamicUIBuilderContext),
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      radius: TypeParser.parseDouble(
        getValue(parsedJson, "radius", null, dynamicUIBuilderContext),
      ),
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
    );
  }
}
