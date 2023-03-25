import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

import '../../util.dart';

class AppBarWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return AppBar(
      key: Util.getKey(),
      title: render(parsedJson, 'title', '', dynamicUIBuilderContext),
      actions: renderList(parsedJson, 'actions', dynamicUIBuilderContext),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Opacity(
          opacity: 0.2,
          child: Container(
            color: TypeParser.parseColor("schema:secondary"),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
