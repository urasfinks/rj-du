import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme_provider.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';

import '../../util.dart';

class AppBarWidget extends AbstractWidget {

  Widget getOld(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
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

  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    //var colorScheme = Theme.of(NavigatorApp.getLast()!.context!).colorScheme;
    return AppBar(
      key: Util.getKey(),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: ThemeProvider.blur, sigmaY: ThemeProvider.blur),
          child: Container(color: Colors.transparent,),
        ),
      ),
      title: render(parsedJson, 'title', '', dynamicUIBuilderContext),
      actions: renderList(parsedJson, 'actions', dynamicUIBuilderContext),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Opacity(
          opacity: 0.1,
          child: Container(
            color: TypeParser.parseColor("schema:secondary"),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
