import 'package:flutter/material.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../dynamic_ui/type_parser.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../navigator_app.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class AlertHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    Map<String, dynamic> config = Util.merge({
      "label": "Сохранено",
      "backgroundColor": "schema:background", // "rgba:30,136,229,0.95",
      "color": "schema:inversePrimary",
      "duration": 750,
      "action": false,
      "actionColor": "white",
      "actionLabel": "Удалить",
    }, args);

    config["backgroundColor"] =
        Util.template(config["backgroundColor"], dynamicUIBuilderContext);
    config["color"] = Util.template(config["color"], dynamicUIBuilderContext);

    SnackBarAction? action = config["action"] == true
        ? SnackBarAction(
            textColor: TypeParser.parseColor(config["actionColor"]),
            label: config["actionLabel"],
            onPressed: () {
              AbstractWidget.clickStatic(config, dynamicUIBuilderContext);
            },
          )
        : null;

    if (config["confirm"] == true) {
      config["action"] = true;
      config["duration"] = 5000;
      config["backgroundColor"] = "red.600";
    }

    if (config["action"] == true) {
      config["duration"] = 3000;
    }

    alert(config["duration"], config["label"], config["color"],
        config["backgroundColor"], action);
  }

  static void alertSimple(String label) {
    alert(700, label, "schema:inversePrimary", "schema:background", null);
  }

  static void alert(int milliseconds, String label, String color,
      String backgroundColor, SnackBarAction? action) {
    ScaffoldMessenger.of(NavigatorApp.getLast()!.context!).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: milliseconds),
        content:
            Text(label, style: TextStyle(color: TypeParser.parseColor(color))),
        backgroundColor: TypeParser.parseColor(backgroundColor),
        behavior: SnackBarBehavior.fixed,
        elevation: 0,
        action: action,
      ),
    );
  }
}
