import 'package:flutter/material.dart';
import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class CustomScrollViewWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<SliverList> sliverList = [];
    const numberOfItemsPerList = 10;
    List children =
        updateList(parsedJson["children"] as List, dynamicUIBuilderContext);

    List<Widget> list = [];
    bool includeTopOffset = TypeParser.parseBool(
      getValue(parsedJson, 'includeTopOffset', true, dynamicUIBuilderContext),
    )!;
    double extraTopOffset = TypeParser.parseDouble(
      getValue(parsedJson, 'extraTopOffset', 0, dynamicUIBuilderContext),
    )!;
    if (includeTopOffset) {
      list.add(SizedBox(
        height: GlobalSettings().appBarHeight + extraTopOffset,
      ));
    }
    for (int i = 0; i < children.length; i++) {
      list.add(getRender(i, children, dynamicUIBuilderContext));
      if (i > 0 && i % numberOfItemsPerList == 0) {
        sliverList.add(getSliverList(list));
        list.clear();
      }
    }
    bool includeBottomOffset = TypeParser.parseBool(
      getValue(
          parsedJson, 'includeBottomOffset', true, dynamicUIBuilderContext),
    )!;
    double extraBottomOffset = TypeParser.parseDouble(
      getValue(parsedJson, 'extraBottomOffset', 0, dynamicUIBuilderContext),
    )!;
    if (includeBottomOffset) {
      list.add(SizedBox(
        height: GlobalSettings().bottomNavigationBarHeight + extraBottomOffset,
      ));
    }
    if (list.isNotEmpty) {
      sliverList.add(getSliverList(list));
    }
    return CustomScrollView(
      key: Util.getKey(),
      primary: TypeParser.parseBool(
        getValue(parsedJson, 'primary', true, dynamicUIBuilderContext),
      ),
      reverse: TypeParser.parseBool(
        getValue(parsedJson, 'reverse', false, dynamicUIBuilderContext),
      )!,
      scrollDirection: TypeParser.parseAxis(
        getValue(parsedJson, 'scrollDirection', 'vertical',
            dynamicUIBuilderContext)!,
      )!,
      //False по умолчанию, потому что высота самого ScrollView будет в размер всех блоков
      //Когда блоков не так много при скроле вниз будет скрывать содержимое не доходя до bottomTab
      shrinkWrap: TypeParser.parseBool(
        getValue(parsedJson, 'shrinkWrap', false, dynamicUIBuilderContext),
      )!,
      cacheExtent: TypeParser.parseDouble(
        getValue(parsedJson, 'radius', null, dynamicUIBuilderContext),
      ),
      slivers: sliverList,
    );
  }

  Widget getRender(int index, List children,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
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
      key: Util.getKey(),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => list[index],
        childCount: list.length,
      ),
    );
  }
}
