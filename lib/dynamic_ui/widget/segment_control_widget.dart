import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class SegmentControlWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String key = getValue(parsedJson, 'name', '-', dynamicUIBuilderContext);
    int value = TypeParser.parseInt(
      getValue(parsedJson, 'value', 0, dynamicUIBuilderContext),
    )!;
    dynamicUIBuilderContext.dynamicPage.setStateData(key, value);

    List<Widget> children = renderList(parsedJson, 'children', dynamicUIBuilderContext);
    Map<int, Widget> ch = {};
    int count = 0;
    for (Widget w in children) {
      ch[count++] = w;
    }

    return CustomSlidingSegmentedControl(
      key: Util.getKey(),
      children: ch,
      decoration: render(parsedJson, 'decoration', null, dynamicUIBuilderContext),
      thumbDecoration: render(parsedJson, 'thumbDecoration', null, dynamicUIBuilderContext),
      duration: Duration(
        milliseconds: TypeParser.parseInt(
          getValue(parsedJson, 'duration', 300, dynamicUIBuilderContext),
        )!,
      ),
      fixedWidth: TypeParser.parseDouble(
        getValue(parsedJson, 'fixedWidth', null, dynamicUIBuilderContext),
      ),
      height: TypeParser.parseDouble(
        getValue(parsedJson, 'height', null, dynamicUIBuilderContext),
      ),
      padding: TypeParser.parseDouble(
        getValue(parsedJson, 'padding', 12, dynamicUIBuilderContext),
      )!,
      fromMax: TypeParser.parseBool(
        getValue(parsedJson, 'fromMax', false, dynamicUIBuilderContext),
      )!,
      isStretch: TypeParser.parseBool(
        getValue(parsedJson, 'isStretch', true, dynamicUIBuilderContext),
      )!,
      onValueChanged: (int index) {
        dynamicUIBuilderContext.dynamicPage.setStateData(key, index);
        click(parsedJson, dynamicUIBuilderContext, "onChanged");
      },
      initialValue: value,
      innerPadding: TypeParser.parseEdgeInsets(
        getValue(parsedJson, 'padding', 2.0, dynamicUIBuilderContext),
      )!,
    );
  }
}
