import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';

class ScaffoldWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    // Если использовать привычный Util.getKey() - то получаем ошибку:
    // At this point the state of the widget's element tree is no longer stable
    // При попытке вызова метода HideHandler(snackBar)
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: TypeParser.parseColor(
        getValue(parsedJson, "backgroundColor", null, dynamicUIBuilderContext),
      ),
      extendBodyBehindAppBar: TypeParser.parseBool(
        getValue(parsedJson, "extendBodyBehindAppBar", true, dynamicUIBuilderContext),
      )!,
      extendBody: TypeParser.parseBool(
        getValue(parsedJson, "extendBody", false, dynamicUIBuilderContext),
      )!,
      appBar: render(parsedJson, "appBar", null, dynamicUIBuilderContext),
      body: render(parsedJson, "body", const SizedBox(), dynamicUIBuilderContext),
      key: _scaffoldKey,
    );
  }
}
