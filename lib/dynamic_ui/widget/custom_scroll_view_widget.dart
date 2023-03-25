import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class CustomScrollViewWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<SliverList> sliverList = [];
    const numberOfItemsPerList = 5;
    List children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    List<Widget> list = [];
    for (int i = 0; i < children.length; i++) {
      list.add(getRender(i, children, dynamicUIBuilderContext));
      if (i > 0 && i % numberOfItemsPerList == 0) {
        sliverList.add(getSliverList(list));
        list.clear();
      }
    }
    if (list.isNotEmpty) {
      sliverList.add(getSliverList(list));
    }
    return CustomScrollView(
      key: Util.getKey(),
      reverse: TypeParser.parseBool(
        getValue(parsedJson, 'reverse', false, dynamicUIBuilderContext),
      )!,
      scrollDirection: TypeParser.parseAxis(
        getValue(parsedJson, 'scrollDirection', 'vertical', dynamicUIBuilderContext)!,
      )!,
      shrinkWrap: TypeParser.parseBool(
        getValue(parsedJson, 'shrinkWrap', false, dynamicUIBuilderContext),
      )!,
      cacheExtent: TypeParser.parseDouble(
        getValue(parsedJson, 'radius', null, dynamicUIBuilderContext),
      ),
      slivers: sliverList,
    );
  }

  Widget getRender(int index, List children, DynamicUIBuilderContext dynamicUIBuilderContext) {
    DynamicUIBuilderContext newContext = children[index]["context"] != null
        ? dynamicUIBuilderContext.cloneWithNewData(children[index]["context"])
        : dynamicUIBuilderContext.clone();
    newContext.index = index;
    return render(children[index], null, null, newContext);
  }

  SliverList getSliverList(List<Widget> defList) {
    final List<Widget> list = [];
    list.addAll(defList);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => list[index],
        childCount: list.length,
      ),
    );
  }
}
