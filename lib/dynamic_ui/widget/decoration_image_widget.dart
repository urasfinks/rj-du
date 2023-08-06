import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';

import '../type_parser.dart';

class DecorationImageWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    return DecorationImage(
      image: render(parsedJson, "image", null, dynamicUIBuilderContext),
      fit: TypeParser.parseBoxFit(
        getValue(parsedJson, "fit", null, dynamicUIBuilderContext),
      ),
    );
  }
}
