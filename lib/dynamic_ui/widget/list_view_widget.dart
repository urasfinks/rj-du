import 'package:rjdu/dynamic_ui/widget/scrollbar_widget.dart';

import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import 'package:flutter/material.dart';
import '../../util.dart';

class ListViewWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    bool separated = TypeParser.parseBool(
      getValue(parsedJson, "separated", false, dynamicUIBuilderContext),
    )!;

    List children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    ScrollController controller = getController(parsedJson, "ScrollBarController", dynamicUIBuilderContext, () {
      return ScrollControllerWrap(ScrollController());
    });
    if (separated) {
      return ListView.separated(
        key: Util.getKey(),
        controller: controller,
        addAutomaticKeepAlives: true,
        scrollDirection: TypeParser.parseAxis(
          getValue(parsedJson, "scrollDirection", "vertical", dynamicUIBuilderContext)!,
        )!,
        padding: TypeParser.parseEdgeInsets(
          getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
        ),
        shrinkWrap: TypeParser.parseBool(
          getValue(parsedJson, "shrinkWrap", true, dynamicUIBuilderContext),
        )!,
        reverse: TypeParser.parseBool(
          getValue(parsedJson, "reverse", false, dynamicUIBuilderContext),
        )!,
        physics: Util.getPhysics(),
        itemCount: TypeParser.parseInt(
          getValue(parsedJson, "itemCount", children.length, dynamicUIBuilderContext),
        )!,
        itemBuilder: (BuildContext context, int index) {
          return render(children[index], null, null, dynamicUIBuilderContext);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          height: 1,
        ),
      );
    } else {
      return ListView.builder(
        key: Util.getKey(),
        controller: controller,
        addAutomaticKeepAlives: true,
        scrollDirection: TypeParser.parseAxis(
          getValue(parsedJson, "scrollDirection", "vertical", dynamicUIBuilderContext)!,
        )!,
        padding: TypeParser.parseEdgeInsets(
          getValue(parsedJson, "padding", null, dynamicUIBuilderContext),
        ),
        shrinkWrap: TypeParser.parseBool(
          getValue(parsedJson, "shrinkWrap", true, dynamicUIBuilderContext),
        )!,
        reverse: TypeParser.parseBool(
          getValue(parsedJson, "reverse", false, dynamicUIBuilderContext),
        )!,
        physics: Util.getPhysics(),
        itemCount: TypeParser.parseInt(
          getValue(parsedJson, "itemCount", children.length, dynamicUIBuilderContext),
        )!,
        itemBuilder: (BuildContext context, int index) {
          return render(children[index], null, null, dynamicUIBuilderContext);
        },
      );
    }
  }
}
