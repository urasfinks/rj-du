import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter/material.dart';

import '../dynamic_ui.dart';
import 'abstract_widget.dart';

class SwipableStackWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SwipableStack(
      detectableSwipeDirections: const {
        SwipeDirection.right,
        SwipeDirection.left,
      },
      stackClipBehaviour: Clip.none,
      onSwipeCompleted: (index, direction) {
        if (kDebugMode) {
          print('$index, $direction');
        }
      },
      horizontalSwipeThreshold: 0.7,
      verticalSwipeThreshold: 0.7,
      overlayBuilder: (context, properties) {
        final opacity = min(properties.swipeProgress, 1.0);
        String to = properties.direction == SwipeDirection.right ? "Знаю" : "Не знаю";
        return Opacity(
          opacity: opacity,
          child: Text(
            to,
            textAlign: TextAlign.end,
          ),
        );
      },
      builder: (context, properties) {
        //final itemIndex = properties.index;
        return render(parsedJson, "children", DynamicUI.ui["SizedBox"]!(parsedJson, dynamicUIBuilderContext),
            dynamicUIBuilderContext);
      },
    );
  }
}
