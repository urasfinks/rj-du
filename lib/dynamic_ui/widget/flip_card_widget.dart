import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../dynamic_ui.dart';
import '../type_parser.dart';

class FlipCardWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String key = parsedJson["key"];
    Map<String, dynamic> defControl = {
      "value": 0,
      "isBack": TypeParser.parseBool(
        getValue(parsedJson, 'isBack', false, dynamicUIBuilderContext),
      )!,
      "flip": TypeParser.parseBool(
        getValue(parsedJson, 'flip', false, dynamicUIBuilderContext),
      )!
    };
    Map<String, dynamic> stateControl = dynamicUIBuilderContext.dynamicPage.getStateData(key, defControl, true);
    bool isBack = stateControl["isBack"];
    return GestureDetector(
      onTap: () {
        dynamicUIBuilderContext.dynamicPage.dynamicPageSate!.setState(() {
          stateControl["isBack"] = !stateControl["isBack"];
          stateControl["flip"] = true;
        });
      },
      child: stateControl["flip"]
          ? TweenAnimationBuilder(
              tween: Tween<double>(begin: isBack ? 0 : 180, end: isBack ? 180 : 0),
              duration: Duration(
                milliseconds: TypeParser.parseInt(
                  getValue(parsedJson, 'duration', 350, dynamicUIBuilderContext),
                )!,
              ),
              builder: (context, val, __) {
                bool isSideBack = val >= (180 / 2);
                if (isSideBack == isBack) {
                  stateControl["flip"] = false;
                }
                stateControl["value"] = val;
                Widget widget = render(
                  parsedJson,
                  (isSideBack ? "back" : "front"),
                  DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
                  dynamicUIBuilderContext,
                );
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(val * pi / 180),
                  child: isSideBack
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: widget,
                        )
                      : widget,
                );
              },
            )
          : render(
              parsedJson,
              (isBack ? "back" : "front"),
              DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
              dynamicUIBuilderContext,
            ),
    );
  }
}
