import 'dart:async';
import 'dart:math';

import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter/material.dart';

import '../dynamic_ui.dart';
import '../type_parser.dart';
import 'abstract_widget.dart';

class SwipableStackWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> stateControl = getStateControl(
      parsedJson["key"],
      dynamicUIBuilderContext,
      {
        "index": 0,
        "swipedIndex": null,
        "swipedDirection": null,
        "overlayDirection": null,
        "overlayOpacity": 0,
      },
    );
    //print("SwipableStack key: ${parsedJson["key"]}; state: $stateControl");
    Set<SwipeDirection> swipeDirection = {};
    if (parsedJson.containsKey("directions")) {
      List list = parsedJson["directions"];
      for (String direction in list) {
        switch (direction.toString()) {
          case "right":
            swipeDirection.add(SwipeDirection.right);
            break;
          case "left":
            swipeDirection.add(SwipeDirection.left);
            break;
          case "up":
            swipeDirection.add(SwipeDirection.up);
            break;
          case "down":
            swipeDirection.add(SwipeDirection.down);
            break;
        }
      }
    } else {
      swipeDirection.add(SwipeDirection.right);
      swipeDirection.add(SwipeDirection.left);
    }

    dynamic swipeAnchor;
    if (parsedJson.containsKey("swipeAnchor")) {
      switch (parsedJson["swipeAnchor"]) {
        case "top":
          swipeAnchor = SwipeAnchor.top;
          break;
        case "bottom":
          swipeAnchor = SwipeAnchor.bottom;
          break;
      }
    }

    final controller = SwipableStackController();
    controller.addListener(() {
      stateControl["index"] = controller.currentIndex;
    });

    List children = [];
    if (parsedJson.containsKey('children')) {
      children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    }

    //print("SwipableStackWidget children: $children");
    Timer? timer;
    bool roll = TypeParser.parseBool(
      getValue(parsedJson, 'roll', true, dynamicUIBuilderContext),
    )!;
    int rollIndex = TypeParser.parseInt(
      getValue(parsedJson, 'rollIndex', 0, dynamicUIBuilderContext),
    )!;
    return SwipableStack(
      viewFraction: TypeParser.parseDouble(
        getValue(parsedJson, 'viewFraction', 0.94, dynamicUIBuilderContext),
      )!,
      allowVerticalSwipe: TypeParser.parseBool(
        getValue(parsedJson, 'allowVerticalSwipe', true, dynamicUIBuilderContext),
      )!,
      swipeAnchor: swipeAnchor,
      controller: controller,
      detectableSwipeDirections: swipeDirection,
      stackClipBehaviour: TypeParser.parseClip(
        getValue(parsedJson, 'stackClipBehaviour', 'none', dynamicUIBuilderContext),
      )!,
      onSwipeCompleted: (index, direction) {
        stateControl["swipedIndex"] = index;
        stateControl["swipedDirection"] = direction.name.toString();
        // if (kDebugMode) {
        //   print('onSwipeCompleted $index, $direction');
        // }
        click(parsedJson, dynamicUIBuilderContext, "onSwipeCompleted");
        if (controller.currentIndex == children.length - 1) {
          if (roll) {
            if (timer != null) {
              timer!.cancel();
            }
            int rollDelay = TypeParser.parseInt(
              getValue(parsedJson, 'rollDelay', 0, dynamicUIBuilderContext),
            )!;
            timer = Timer(Duration(seconds: rollDelay), () {
              controller.currentIndex = rollIndex;
            });
          }
          click(parsedJson, dynamicUIBuilderContext, "onFinish");
        }
      },
      onWillMoveNext: (index, direction) {
        stateControl["swipedIndex"] = index;
        stateControl["swipedDirection"] = direction.name.toString();
        // if (kDebugMode) {
        //   print('onWillMoveNext $index, $direction');
        // }
        click(parsedJson, dynamicUIBuilderContext, "onWillMoveNext");
        return true;
      },
      horizontalSwipeThreshold: TypeParser.parseDouble(
        getValue(parsedJson, 'horizontalSwipeThreshold', 0.7, dynamicUIBuilderContext),
      )!,
      verticalSwipeThreshold: TypeParser.parseDouble(
        getValue(parsedJson, 'verticalSwipeThreshold', 0.7, dynamicUIBuilderContext),
      )!,
      overlayBuilder: (context, properties) {
        stateControl["overlayOpacity"] = min(properties.swipeProgress, 1.0);
        stateControl["overlayDirection"] = properties.direction.name.toString();
        return render(
          parsedJson,
          "overlay",
          DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
          dynamicUIBuilderContext,
        );
      },
      builder: (context, properties) {
        if (properties.index < children.length) {
          return render(children[properties.index], null, const SizedBox(), dynamicUIBuilderContext);
        } else {
          if (roll) {
            return render(children[rollIndex], null, const SizedBox(), dynamicUIBuilderContext);
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }
}
