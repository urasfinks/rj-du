import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../data_type.dart';
import '../../db/data.dart';
import '../../db/data_source.dart';
import '../type_parser.dart';

class FlipCardWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> stateControl = getStateControl(
      parsedJson["key"],
      dynamicUIBuilderContext,
      {
        "angle": 0,
        "isBack": TypeParser.parseBool(
          getValue(parsedJson, "isBack", false, dynamicUIBuilderContext),
        )!,
        "flip": TypeParser.parseBool(
          getValue(parsedJson, "flip", false, dynamicUIBuilderContext),
        )!
      },
    );
    // Data создаётся, для того, что бы можно было выставить Notify на обновление состояний FlipCard
    Data stateDataFlipCard = Data(parsedJson["key"], stateControl, DataType.virtual, null);
    return dynamicUIBuilderContext.dynamicPage.storeValueNotifier.getWidget(
      {"state": parsedJson["key"]},
      dynamicUIBuilderContext,
      (context, child) {
        bool isBack = stateControl["isBack"];
        return GestureDetector(
          onTap: () {
            stateControl["isBack"] = !stateControl["isBack"];
            stateControl["flip"] = true;
            click(parsedJson, dynamicUIBuilderContext, "onTap");
            DataSource().setData(stateDataFlipCard, true);
          },
          child: stateControl["flip"]
              ? TweenAnimationBuilder(
                  tween: Tween<double>(begin: isBack ? 0 : 180, end: isBack ? 180 : 0),
                  duration: Duration(
                    milliseconds: TypeParser.parseInt(
                      getValue(parsedJson, "duration", 350, dynamicUIBuilderContext),
                    )!,
                  ),
                  builder: (context, val, __) {
                    bool isSideBack = val >= (180 / 2);
                    if (isSideBack == isBack && stateControl["flip"] == true) {
                      stateControl["flip"] = false;
                      click(parsedJson, dynamicUIBuilderContext, isBack ? "onFlipBack" : "onFlipFront");
                    }
                    stateControl["angle"] = val;
                    Widget widget = render(
                      parsedJson,
                      (isSideBack ? "back" : "front"),
                      const SizedBox(),
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
                  const SizedBox(),
                  dynamicUIBuilderContext,
                ),
        );
      },
    );
  }
}
