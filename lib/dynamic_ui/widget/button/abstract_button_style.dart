import 'package:flutter/material.dart';

import '../../dynamic_ui_builder_context.dart';
import '../abstract_widget.dart';

abstract class AbstractButtonStyle {
  DynamicUIBuilderContext dynamicUIBuilderContext;
  AbstractWidget abstractWidget;
  Map<String, dynamic> parsedJson;

  AbstractButtonStyle(
      this.dynamicUIBuilderContext, this.abstractWidget, this.parsedJson);

  dynamic getValue(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    return abstractWidget.getValue(
        parsedJson, key, defaultValue, dynamicUIBuilderContext);
  }

  ButtonStyle getStadiumBorder();

  ButtonStyle getRoundedRectangleBorder();

  ButtonStyle getCircleBorder();

  Widget getButton(ButtonStyle? resultButtonStyle);
}
