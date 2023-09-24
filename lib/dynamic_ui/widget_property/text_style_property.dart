import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

class TextStyleProperty extends AbstractWidget {
  @override
  dynamic get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String textTheme = getValue(parsedJson, "textTheme", "default", dynamicUIBuilderContext);
    if (textTheme == "default") {
      return TextStyle(
        decoration: TypeParser.parseTextDecoration(
          getValue(parsedJson, "decoration", null, dynamicUIBuilderContext),
        ),
        color: TypeParser.parseColor(
          getValue(parsedJson, "color", null, dynamicUIBuilderContext),
        ),
        fontSize: TypeParser.parseDouble(
          getValue(parsedJson, "fontSize", 15, dynamicUIBuilderContext),
        ),
        fontStyle: TypeParser.parseFontStyle(
          getValue(parsedJson, "fontStyle", null, dynamicUIBuilderContext),
        ),
        fontWeight: TypeParser.parseFontWeight(
          getValue(parsedJson, "fontWeight", null, dynamicUIBuilderContext),
        ),
      );
    } else if (textTheme == "Large") {
      return Theme.of(dynamicUIBuilderContext.dynamicPage.context!).textTheme.titleLarge;
    } else if (textTheme == "Medium") {
      return Theme.of(dynamicUIBuilderContext.dynamicPage.context!).textTheme.titleMedium;
    } else {
      return Theme.of(dynamicUIBuilderContext.dynamicPage.context!).textTheme.titleSmall;
    }
  }
}
