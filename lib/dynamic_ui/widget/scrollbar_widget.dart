import 'package:flutter/material.dart';
import 'package:rjdu/controller_wrap.dart';
import '../../dynamic_invoke/handler/alert_handler.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class ScrollbarWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    ScrollController controller = getController(parsedJson, "ScrollBarController", dynamicUIBuilderContext, () {
      return ScrollControllerWrap(ScrollController());
    });
    return Scrollbar(
      controller: controller,
      child: render(parsedJson, "child", null, dynamicUIBuilderContext),
      key: Util.getKey(),
    );
  }
}

class ScrollControllerWrap extends ControllerWrap<ScrollController> {
  ScrollControllerWrap(super.controller);

  @override
  void dispose() {
    controller.dispose();
  }

  @override
  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "default") {
      case "jumpTo":
        controller.jumpTo(TypeParser.parseDouble(
          AbstractWidget.getValueStatic(args, "offset", 0, dynamicUIBuilderContext),
        )!);
        break;
      case "animateTo":
        controller.animateTo(
          TypeParser.parseDouble(
            AbstractWidget.getValueStatic(args, "offset", 0, dynamicUIBuilderContext),
          )!,
          duration: Duration(
              seconds: TypeParser.parseInt(
            AbstractWidget.getValueStatic(args, "duration", 1, dynamicUIBuilderContext),
          )!),
          curve: TypeParser.parseCurve(
            AbstractWidget.getValueStatic(args, "curve", "fastOutSlowIn", dynamicUIBuilderContext),
          )!,
        );
        break;
      default:
        AlertHandler.alertSimple("ScrollControllerWrap.invoke() args: $args");
        break;
    }
  }
}
