import 'package:flutter/material.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../dynamic_ui/type_parser.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../navigator_app.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class AlertHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    try {
      ScaffoldMessenger.of(dynamicUIBuilderContext.dynamicPage.context!).hideCurrentSnackBar();
    } catch (error, stackTrace) {
      Util.log("AlertHandler ars: $args; Error: $error", stackTrace: stackTrace, type: "error");
    }
    Map<String, dynamic> config = Util.merge({
      "label": "Сохранено",
      "backgroundColor": "schema:background", // "rgba:30,136,229,0.95",
      "color": "schema:inversePrimary",
      "duration": 1500,
      "action": false,
      "actionColor": "white",
      "actionBackgroundColor": "transparent",
      "actionLabel": "Удалить",
    }, args);

    config["backgroundColor"] = Util.template(config["backgroundColor"], dynamicUIBuilderContext);
    config["color"] = Util.template(config["color"], dynamicUIBuilderContext);

    if (config["confirmRemove"] == true) {
      config["action"] = true;
      if (!args.containsKey("label")) {
        config["label"] = "Подтвердить действие:";
      }
      if (!args.containsKey("duration")) {
        config["duration"] = 5000;
      }
      if (!args.containsKey("backgroundColor")) {
        config["backgroundColor"] = "schema:background";
      }
      if (!args.containsKey("actionBackgroundColor")) {
        config["actionBackgroundColor"] = "red.600";
      }
    }

    if (config["confirmAction"] == true) {
      config["action"] = true;
      if (!args.containsKey("label")) {
        config["label"] = "Подтвердить действие:";
      }
      if (!args.containsKey("duration")) {
        config["duration"] = 5000;
      }
      if (!args.containsKey("backgroundColor")) {
        config["backgroundColor"] = "schema:background";
      }
      if (!args.containsKey("actionLabel")) {
        config["actionLabel"] = "Да";
      }
      if (!args.containsKey("actionBackgroundColor")) {
        config["actionBackgroundColor"] = "schema:projectPrimary";
      }
    }

    SnackBarAction? action = config["action"] == true
        ? SnackBarAction(
            textColor: TypeParser.parseColor(config["actionColor"]),
            backgroundColor: TypeParser.parseColor(config["actionBackgroundColor"]),
            label: config["actionLabel"],
            onPressed: () {
              AbstractWidget.clickStatic(config, dynamicUIBuilderContext, "onPressed");
            },
          )
        : null;

    alert(config["duration"], config["label"], config["color"], config["backgroundColor"], action);
  }

  static void alertSimple(String label) {
    alert(1500, label, "schema:inversePrimary", "schema:background", null);
  }

  static void alert(int milliseconds, String label, String color, String backgroundColor, SnackBarAction? action) {
    Util.p("!!!", true);
    if (NavigatorApp.getLast() != null) {
      ScaffoldMessenger.of(NavigatorApp.getLast()!.context!).showSnackBar(
        SnackBar(
          padding: TypeParser.parseEdgeInsets("17,13,10,13")!,
          margin: TypeParser.parseEdgeInsets("10")!,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          duration: Duration(milliseconds: milliseconds),
          content: Text(label, style: TextStyle(color: TypeParser.parseColor(color))),
          backgroundColor: TypeParser.parseColor(backgroundColor)?.withOpacity(0.98),
          behavior: SnackBarBehavior.floating,
          elevation: 60,
          action: action,
        ),
      );
    }
  }
}
