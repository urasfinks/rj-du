import 'dart:math';

import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/util.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter/material.dart';

import '../../abstract_controller_wrap.dart';
import '../../dynamic_invoke/handler/alert_handler.dart';
import '../../multi_invoke.dart';
import '../dynamic_ui.dart';
import '../type_parser.dart';
import 'abstract_widget.dart';

enum SwipableEvent {
  setStateOnControllerListen,
  setStateOnSwipeCompleted,
  setStateOnWillMoveNext,
  setStateOnOverlayBuilder,
  setStateOnInit,
  onControllerInvoke
}

class SwipableStackWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    parsedJson["state"] ??= "Key";
    Map<String, dynamic> stateControl = AbstractWidget.getStateControl(
      parsedJson["state"],
      dynamicUIBuilderContext,
      {
        "index": 0,
        "index1": 1,
        "swipedIndex": null,
        "swipedDirection": null,
        "overlayDirection": "null",
        "overlayOpacity": 0,
        "finish": false,
        "prc": 0,
        "prc1": 0,
        "swipedHistory": {},
        "swiped": {}
      },
    );

    SwipableStackController controller = getController(parsedJson, "SwipableStack", dynamicUIBuilderContext, () {
      SwipableStackControllerWrap swipableStackControllerWrap =
          SwipableStackControllerWrap(SwipableStackController(), stateControl);
      swipableStackControllerWrap.setStateKey(parsedJson["state"]);
      return swipableStackControllerWrap;
    });

    double reactionOverlayOpacity = TypeParser.parseDouble(
      getValue(parsedJson, "reactionOverlayOpacity", 0.25, dynamicUIBuilderContext),
    )!;

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

    controller.addListener(() {
      int index = min(controller.currentIndex, stateControl["size"] - 1);
      stateControl["index"] = index;
      int index1 = min((controller.currentIndex + 1), stateControl["size"]);
      stateControl["index1"] = index1;

      stateControl["prc"] = (controller.currentIndex * 100 / stateControl["size"]).ceil();
      stateControl["prc1"] = controller.currentIndex * 1 / stateControl["size"];

      if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnControllerListen.name] ?? false == true) {
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

    final MultiInvoke multiInvoke = MultiInvoke(TypeParser.parseInt(
      getValue(parsedJson, "rollDelay", 0, dynamicUIBuilderContext),
    )!);
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
        try {
          Map x = (stateControl["swipedHistory"] as Map);
          x["i$index"] = direction.name.toString();
          calculate(index, stateControl);

          stateControl["swipedIndex"] = index;
          stateControl["swipedDirection"] = direction.name.toString();
          stateControl["overlayDirection"] = "none";
          stateControl["overlayOpacity"] = 0;
          click(parsedJson, dynamicUIBuilderContext, "onSwipeCompleted");
          if (controller.currentIndex == children.length - 1) {
            if (roll) {
              multiInvoke.invoke(() {
                controller.currentIndex = rollIndex;
              });
            } else {
              stateControl["finish"] = true;
              dynamicUIBuilderContext.dynamicPage.reload(false, "SwipableStackWidget.onFinish()");
            }
            click(parsedJson, dynamicUIBuilderContext, "onFinish");
          }

          if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnSwipeCompleted.name] ?? false == true) {
            dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
          }
        } catch (error, stackTrace) {
          Util.printStackTrace("-", error, stackTrace);
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
        getValue(parsedJson, "horizontalSwipeThreshold", 0.32, dynamicUIBuilderContext),
      )!,
      verticalSwipeThreshold: TypeParser.parseDouble(
        getValue(parsedJson, "verticalSwipeThreshold", 0.32, dynamicUIBuilderContext),
      )!,
      overlayBuilder: (context, properties) {
        stateControl["overlayOpacity"] = min(properties.swipeProgress, 1.0);
        if (stateControl["overlayOpacity"] < reactionOverlayOpacity) {
          stateControl["overlayOpacity"] = 0;
          stateControl["overlayDirection"] = "none";
        } else {
          stateControl["overlayDirection"] = properties.direction.name.toString();
        }
        if (parsedJson["setState"] ?? parsedJson[SwipableEvent.setStateOnOverlayBuilder.name] ?? false == true) {
          dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
        }
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

  static void calculate(int currentIndex, Map<String, dynamic> stateControl) {
    try {
      Map x = stateControl["swipedHistory"] as Map;
      Map<String, int> swipedCounter = {};
      x.forEach((key, value) {
        int? i = TypeParser.parseInt(key.toString().substring(1));
        String direction = value.toString();
        if (i != null) {
          if (!swipedCounter.containsKey(direction)) {
            swipedCounter[direction] = 0;
          }
          if (i <= currentIndex) {
            swipedCounter[direction] = swipedCounter[direction]! + 1;
          }
        }
      });
      stateControl["swiped"] = swipedCounter;
    } catch (error, stackTrace) {
      Util.printStackTrace("", error, stackTrace);
    }
  }
}

class SwipableStackControllerWrap extends AbstractControllerWrap<SwipableStackController> {
  SwipableStackControllerWrap(super.controller, super.stateControl);

  String? stateKey;

  void setStateKey(String stateKey) {
    this.stateKey = stateKey;
  }

  @override
  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "default") {
      case "index":
        controller.currentIndex = args["index"] ?? 0;
        stateControl["index"] = controller.currentIndex;
        SwipableStackWidget.calculate(controller.currentIndex - 1, stateControl);
        break;
      case "next":
        switch (args["direction"] ?? "right") {
          case "right":
            controller.next(swipeDirection: SwipeDirection.right);
            break;
          case "left":
            controller.next(swipeDirection: SwipeDirection.left);
            break;
          case "up":
            controller.next(swipeDirection: SwipeDirection.up);
            break;
          case "down":
            controller.next(swipeDirection: SwipeDirection.down);
            break;
        }
        stateControl["index"] = controller.currentIndex;
        SwipableStackWidget.calculate(controller.currentIndex - 1, stateControl);
        break;
      case "cancelAction":
        controller.cancelAction();
        break;
      case "rewind":
        controller.rewind();
        stateControl["index"] = controller.currentIndex;
        SwipableStackWidget.calculate(controller.currentIndex - 1, stateControl);
        break;
      case "dispose":
        controller.dispose();
        break;
      default:
        AlertHandler.alertSimple("SwipableStackControllerWrap.invoke() args: $args");
        break;
    }
    if (args["setState"] ?? args[SwipableEvent.onControllerInvoke.name] ?? false == true && stateKey != null) {
      dynamicUIBuilderContext.dynamicPage.stateData.setMap(stateKey, stateControl);
    }
  }

  @override
  void dispose() {
    controller.dispose();
  }
}
