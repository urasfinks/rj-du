import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:rjdu/global_settings.dart';

import '../../theme_provider.dart';
import '../type_parser.dart';

class SliverAppBarWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return SliverAppBar(
      pinned: TypeParser.parseBool(
        getValue(parsedJson, "pinned", true, dynamicUIBuilderContext),
      )!,
      floating: TypeParser.parseBool(
        getValue(parsedJson, "floating", false, dynamicUIBuilderContext),
      )!,
      expandedHeight: TypeParser.parseDouble(
        getValue(parsedJson, "expandedHeight", null, dynamicUIBuilderContext),
      ),
      elevation: TypeParser.parseDouble(
        getValue(parsedJson, "elevation", 0, dynamicUIBuilderContext),
      ),
      centerTitle: TypeParser.parseBool(
        getValue(parsedJson, "centerTitle", true, dynamicUIBuilderContext),
      )!,
      title: render(parsedJson, "title", "", dynamicUIBuilderContext),
      actions: renderList(parsedJson, "actions", dynamicUIBuilderContext),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: ThemeProvider.blur, sigmaY: ThemeProvider.blur),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Opacity(
          opacity: GlobalSettings().barSeparatorOpacity,
          child: Container(
            color: TypeParser.parseColor("schema:secondary"),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
