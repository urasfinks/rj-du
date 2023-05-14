import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';
import 'package:flutter/material.dart';

class ScaffoldWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: false,
      appBar: render(parsedJson, 'appBar', null, dynamicUIBuilderContext),
      body: render(parsedJson, 'body', const SizedBox(), dynamicUIBuilderContext),
      key: Util.getKey(),
    );
  }
}
