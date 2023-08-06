import 'package:flutter/material.dart';

import '../../../util.dart';
import '../../type_parser.dart';
import 'abstract_button_style.dart';

class TextButtonStyle extends AbstractButtonStyle {
  TextButtonStyle(
      super.dynamicUIBuilderContext, super.abstractWidget, super.parsedJson);

  @override
  ButtonStyle getStadiumBorder() {
    //------------------------
    return TextButton.styleFrom(
      minimumSize: TypeParser.parseSize(
          getValue(parsedJson, "minimumSize", null, dynamicUIBuilderContext)),
      maximumSize: TypeParser.parseSize(
          getValue(parsedJson, "maximumSize", null, dynamicUIBuilderContext)),
      fixedSize: TypeParser.parseSize(
          getValue(parsedJson, "fixedSize", null, dynamicUIBuilderContext)),
      textStyle: abstractWidget.render(
          parsedJson, "textStyle", null, dynamicUIBuilderContext),
      side: abstractWidget.render(
          parsedJson, "side", null, dynamicUIBuilderContext),
      alignment: TypeParser.parseAlignmentDirectional(
        getValue(parsedJson, "alignment", null, dynamicUIBuilderContext),
      ),
      surfaceTintColor: TypeParser.parseColor(
        getValue(parsedJson, "surfaceTintColor", null, dynamicUIBuilderContext),
      ),
      shadowColor: TypeParser.parseColor(
        getValue(parsedJson, "shadowColor", "transparent", dynamicUIBuilderContext),
      ),
      foregroundColor: TypeParser.parseColor(
        getValue(parsedJson, "foregroundColor", null, dynamicUIBuilderContext),
      ),
      elevation: TypeParser.parseDouble(
        getValue(parsedJson, "elevation", 0, dynamicUIBuilderContext),
      )!,
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      shape: const StadiumBorder(),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
      ),
    );
  }

  @override
  ButtonStyle getRoundedRectangleBorder() {
    //------------------
    return TextButton.styleFrom(
      minimumSize: TypeParser.parseSize(
          getValue(parsedJson, "minimumSize", null, dynamicUIBuilderContext)),
      maximumSize: TypeParser.parseSize(
          getValue(parsedJson, "maximumSize", null, dynamicUIBuilderContext)),
      fixedSize: TypeParser.parseSize(
          getValue(parsedJson, "fixedSize", null, dynamicUIBuilderContext)),
      textStyle: abstractWidget.render(
          parsedJson, "textStyle", null, dynamicUIBuilderContext),
      side: abstractWidget.render(
          parsedJson, "side", null, dynamicUIBuilderContext),
      alignment: TypeParser.parseAlignmentDirectional(
        getValue(parsedJson, "alignment", null, dynamicUIBuilderContext),
      ),
      surfaceTintColor: TypeParser.parseColor(
        getValue(parsedJson, "surfaceTintColor", null, dynamicUIBuilderContext),
      ),
      shadowColor: TypeParser.parseColor(
        getValue(parsedJson, "shadowColor", "transparent", dynamicUIBuilderContext),
      ),
      foregroundColor: TypeParser.parseColor(
        getValue(parsedJson, "foregroundColor", null, dynamicUIBuilderContext),
      ),
      elevation: TypeParser.parseDouble(
        getValue(parsedJson, "elevation", 0, dynamicUIBuilderContext),
      )!,
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: TypeParser.parseBorderRadius(
          getValue(parsedJson, "borderRadius", 4, dynamicUIBuilderContext),
        )!,
      ),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
      ),
    );
  }

  @override
  ButtonStyle getCircleBorder() {
    //------------------------
    return TextButton.styleFrom(
      minimumSize: TypeParser.parseSize(
          getValue(parsedJson, "minimumSize", null, dynamicUIBuilderContext)),
      maximumSize: TypeParser.parseSize(
          getValue(parsedJson, "maximumSize", null, dynamicUIBuilderContext)),
      fixedSize: TypeParser.parseSize(
          getValue(parsedJson, "fixedSize", null, dynamicUIBuilderContext)),
      textStyle: abstractWidget.render(
          parsedJson, "textStyle", null, dynamicUIBuilderContext),
      side: abstractWidget.render(
          parsedJson, "side", null, dynamicUIBuilderContext),
      alignment: TypeParser.parseAlignmentDirectional(
        getValue(parsedJson, "alignment", null, dynamicUIBuilderContext),
      ),
      surfaceTintColor: TypeParser.parseColor(
        getValue(parsedJson, "surfaceTintColor", null, dynamicUIBuilderContext),
      ),
      shadowColor: TypeParser.parseColor(
        getValue(parsedJson, "shadowColor", "transparent", dynamicUIBuilderContext),
      ),
      foregroundColor: TypeParser.parseColor(
        getValue(parsedJson, "foregroundColor", null, dynamicUIBuilderContext),
      ),
      elevation: TypeParser.parseDouble(
        getValue(parsedJson, "elevation", 0, dynamicUIBuilderContext),
      )!,
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      shape: const CircleBorder(),
      padding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
      ),
    );
  }

  @override
  Widget getButton(ButtonStyle? resultButtonStyle) {
    return TextButton(
      key: Util.getKey(),
      onPressed: () {
        abstractWidget.click(parsedJson, dynamicUIBuilderContext);
      },
      child: abstractWidget.render(
          parsedJson, "child", null, dynamicUIBuilderContext),
      style: resultButtonStyle,
    );
  }
}
