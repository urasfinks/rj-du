import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';
import 'dart:math';

import '../type_parser.dart';

class FlipCardWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    StreamCustom stream = getController(parsedJson, "FlipCardWidget", dynamicUIBuilderContext, () {
      return StreamControllerWrap(StreamData({
        "angle": 0,
        "isBack": TypeParser.parseBool(
          getValue(parsedJson, "isBack", false, dynamicUIBuilderContext),
        )!,
        "flip": TypeParser.parseBool(
          getValue(parsedJson, "flip", false, dynamicUIBuilderContext),
        )!
      }));
    });
    return StreamWidget.getWidget(stream, (snapshot) {
      bool isBack = snapshot["isBack"];
      return GestureDetector(
        onTap: () {
          snapshot["isBack"] = !snapshot["isBack"];
          snapshot["flip"] = true;
          click(parsedJson, dynamicUIBuilderContext, "onTap");
          stream.setData(snapshot);
        },
        child: snapshot["flip"]
            ? TweenAnimationBuilder(
                tween: Tween<double>(begin: isBack ? 0 : 180, end: isBack ? 180 : 0),
                duration: Duration(
                  milliseconds: TypeParser.parseInt(
                    getValue(parsedJson, "duration", 350, dynamicUIBuilderContext),
                  )!,
                ),
                builder: (context, val, __) {
                  bool isSideBack = val >= (180 / 2);
                  if (isSideBack == isBack && snapshot["flip"] == true) {
                    snapshot["flip"] = false;
                    click(parsedJson, dynamicUIBuilderContext, isBack ? "onFlipBack" : "onFlipFront");
                  }
                  snapshot["angle"] = val;
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
    });
  }
}
