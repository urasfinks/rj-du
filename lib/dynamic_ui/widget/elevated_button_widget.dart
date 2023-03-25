import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../util.dart';

class ElevatedButtonWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    //GlobalData.debug("pElevatedButton: ${parsedJson}");
    /*
    * [ElevatedButton/OutlinedButton]
    * StadiumBorder
    * RoundedRectangleBorder
    * CircleBorder
    * BeveledRectangleBorder
    * */
    // double borderRadius = TypeParser.parseDouble(
    //   getValue(parsedJson, 'borderRadius', 0, dynamicUIBuilderContext),
    // )!;
    // String buttonStyleType = getValue(parsedJson, 'buttonStyle', 'ElevatedButton', dynamicUIBuilderContext);
    // String shapeType = getValue(parsedJson, 'shape', 'StadiumBorder', dynamicUIBuilderContext);
    // OutlinedBorder? shape;
    //
    // if (shapeType == "StadiumBorder") {
    //   shape = const StadiumBorder();
    // }
    // if (shapeType == "RoundedRectangleBorder") {
    //   shape = RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(borderRadius), // <-- Radius
    //   );
    // }
    // if (shapeType == "CircleBorder") {
    //   shape = const CircleBorder();
    // }
    // if (shapeType == "BeveledRectangleBorder") {
    //   shape = BeveledRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));
    // }
    //
    // ButtonStyle? buttonStyle;
    // if (buttonStyleType == "ElevatedButton") {
    //   buttonStyle = ElevatedButton.styleFrom(shape: shape);
    // }
    // if (buttonStyleType == "OutlinedButton") {
    //   buttonStyle = OutlinedButton.styleFrom(shape: shape);
    // }

    return ElevatedButton(
      key: Util.getKey(),
      onPressed: () {
        click(parsedJson, dynamicUIBuilderContext);
      },
      child: render(parsedJson, 'child', null, dynamicUIBuilderContext),
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
      ),
    );
  }
}
