import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class CheckboxWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String key = getValue(parsedJson, "name", "-", dynamicUIBuilderContext);
    bool value = TypeParser.parseBool(
      getValue(parsedJson, "value", false, dynamicUIBuilderContext),
    )!;
    dynamicUIBuilderContext.dynamicPage.stateData.set(parsedJson["state"], key, value);
    return Checkbox(
      key: Util.getKey(),
      side: MaterialStateBorderSide.resolveWith(
        (states) => BorderSide(
          width: 2.0,
          color: TypeParser.parseColor(
              value == false ? getValue(parsedJson, "borderColor", "grey", dynamicUIBuilderContext) : "transparent")!,
        ),
      ),
      value: TypeParser.parseBool(
        getValue(parsedJson, "value", false, dynamicUIBuilderContext),
      ),
      tristate: TypeParser.parseBool(
        getValue(parsedJson, "tristate", false, dynamicUIBuilderContext),
      )!,
      activeColor: TypeParser.parseColor(
        getValue(parsedJson, "activeColor", null, dynamicUIBuilderContext),
      ),
      focusColor: TypeParser.parseColor(
        getValue(parsedJson, "focusColor", null, dynamicUIBuilderContext),
      ),
      hoverColor: TypeParser.parseColor(
        getValue(parsedJson, "hoverColor", null, dynamicUIBuilderContext),
      ),
      checkColor: TypeParser.parseColor(
        getValue(parsedJson, "checkColor", null, dynamicUIBuilderContext),
      ),
      autofocus: TypeParser.parseBool(
        getValue(parsedJson, "autofocus", false, dynamicUIBuilderContext),
      )!,
      splashRadius: TypeParser.parseDouble(getValue(parsedJson, "splashRadius", null, dynamicUIBuilderContext)),
      onChanged: (bool? value) {
        dynamicUIBuilderContext.dynamicPage.stateData.set(parsedJson["state"], key, value);
        click(parsedJson, dynamicUIBuilderContext, "onChanged");
      },
    );
  }
}
