import '../../util.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import 'button/abstract_button_style.dart';
import 'button/elevated_button_style.dart';
import 'button/outlined_button_style.dart';
import 'button/text_button_style.dart';

class ButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    AbstractButtonStyle? styleResource;
    String? buttonStyle = getValue(parsedJson, "buttonStyle", "Elevated", dynamicUIBuilderContext);
    switch (buttonStyle) {
      case "Elevated":
        styleResource = ElevatedButtonStyle(dynamicUIBuilderContext, this, parsedJson);
        break;
      case "Outlined":
        styleResource = OutlinedButtonStyle(dynamicUIBuilderContext, this, parsedJson);
        break;
      case "Text":
        styleResource = TextButtonStyle(dynamicUIBuilderContext, this, parsedJson);
        break;
    }
    String? borderStyle = getValue(parsedJson, "borderStyle", "RoundedRectangleBorder", dynamicUIBuilderContext);
    ButtonStyle? resultButtonStyle;
    if (borderStyle != null && styleResource != null) {
      switch (borderStyle) {
        case "StadiumBorder":
          resultButtonStyle = styleResource.getStadiumBorder();
          break;
        case "RoundedRectangleBorder":
          resultButtonStyle = styleResource.getRoundedRectangleBorder();
          break;
        case "CircleBorder":
          resultButtonStyle = styleResource.getCircleBorder();
          break;
      }
    }
    if (parsedJson.containsKey("height") || parsedJson.containsKey("width")) {
      return SizedBox(
        key: Util.getKey(),
        width: TypeParser.parseDouble(
          getValue(parsedJson, "width", null, dynamicUIBuilderContext),
        ),
        height: TypeParser.parseDouble(
          getValue(parsedJson, "height", null, dynamicUIBuilderContext),
        ),
        child: styleResource!.getButton(resultButtonStyle),
      );
    } else {
      return styleResource!.getButton(resultButtonStyle);
    }
  }
}
