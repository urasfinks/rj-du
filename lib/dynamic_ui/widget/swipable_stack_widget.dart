import 'dart:async';
import 'dart:math';

import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter/material.dart';

import '../dynamic_ui.dart';
import '../type_parser.dart';
import 'abstract_widget.dart';

enum SwipableEvent {
  setStateOnChangeIndex,
  setStateOnSwipeCompleted,
  setStateOnWillMoveNext,
  setStateOnOverlayBuilder,
  setStateOnInit,
}

class SwipableStackWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> stateControl = AbstractWidget.getStateControl(
      parsedJson["state"],
      dynamicUIBuilderContext,
      {
        "index": 0,
        "index1": 1,
        "swipedIndex": null,
        "swipedDirection": null,
        "overlayDirection": null,
        "overlayOpacity": 0,
        "prc": 0,
        "prc1": 0
      },
    );

    if (parsedJson.containsKey("finish") && stateControl.containsKey("finish") && stateControl["finish"]) {
      return render(parsedJson["finish"], null, const SizedBox(), dynamicUIBuilderContext);
    }

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
      int index = min(controller.currentIndex, stateControl["size"] - 1);
      stateControl["index"] = index;
      int index1 = min((controller.currentIndex + 1), stateControl["size"]);
      stateControl["index1"] = index1;

      stateControl["prc"] = (controller.currentIndex * 100 / stateControl["size"]).ceil();
      stateControl["prc1"] = controller.currentIndex * 1 / stateControl["size"];

      if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnChangeIndex.name] ?? false == true) {
        dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
      }
    });

    List children = [];
    if (parsedJson.containsKey("children")) {
      children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    }
    if (children.isEmpty) {
      return const SizedBox();
    }

    stateControl["size"] = children.length;

    Timer? timer;
    bool roll = TypeParser.parseBool(
      getValue(parsedJson, "roll", true, dynamicUIBuilderContext),
    )!;
    int rollIndex = TypeParser.parseInt(
      getValue(parsedJson, "rollIndex", 0, dynamicUIBuilderContext),
    )!;
    if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnInit.name] ?? false == true) {
      dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
    }
    return SwipableStack(
      viewFraction: TypeParser.parseDouble(
        getValue(parsedJson, "viewFraction", 0.94, dynamicUIBuilderContext),
      )!,
      allowVerticalSwipe: TypeParser.parseBool(
        getValue(parsedJson, "allowVerticalSwipe", true, dynamicUIBuilderContext),
      )!,
      swipeAnchor: swipeAnchor,
      controller: controller,
      detectableSwipeDirections: swipeDirection,
      stackClipBehaviour: TypeParser.parseClip(
        getValue(parsedJson, "stackClipBehaviour", "none", dynamicUIBuilderContext),
      )!,
      onSwipeCompleted: (index, direction) {
        stateControl["swipedIndex"] = index;
        stateControl["swipedDirection"] = direction.name.toString();
        click(parsedJson, dynamicUIBuilderContext, "onSwipeCompleted");
        if (controller.currentIndex == children.length - 1) {
          if (roll) {
            if (timer != null) {
              timer!.cancel();
            }
            int rollDelay = TypeParser.parseInt(
              getValue(parsedJson, "rollDelay", 0, dynamicUIBuilderContext),
            )!;
            timer = Timer(Duration(seconds: rollDelay), () {
              controller.currentIndex = rollIndex;
            });
          } else {
            stateControl["finish"] = true;
            dynamicUIBuilderContext.dynamicPage.reload(false);
          }
          click(parsedJson, dynamicUIBuilderContext, "onFinish");
        }

        if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnSwipeCompleted.name] ?? false == true) {
          dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
        }
      },
      onWillMoveNext: (index, direction) {
        stateControl["swipedIndex"] = index;
        stateControl["swipedDirection"] = direction.name.toString();
        click(parsedJson, dynamicUIBuilderContext, "onWillMoveNext");
        if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnWillMoveNext.name] ?? false == true) {
          dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
        }
        if (controller.currentIndex == children.length && !roll) {
          return false;
        }
        return true;
      },
      horizontalSwipeThreshold: TypeParser.parseDouble(
        getValue(parsedJson, "horizontalSwipeThreshold", 0.7, dynamicUIBuilderContext),
      )!,
      verticalSwipeThreshold: TypeParser.parseDouble(
        getValue(parsedJson, "verticalSwipeThreshold", 0.7, dynamicUIBuilderContext),
      )!,
      overlayBuilder: (context, properties) {
        stateControl["overlayOpacity"] = min(properties.swipeProgress, 1.0);
        stateControl["overlayDirection"] = properties.direction.name.toString();
        if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnOverlayBuilder.name] ?? false == true) {
          dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
        }
        //return Text("wefew");
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
          } else if (parsedJson.containsKey("finish") && properties.index == children.length) {
            return render(parsedJson["finish"], null, const SizedBox(), dynamicUIBuilderContext);
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }
}
