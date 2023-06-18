import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class CustomScrollViewWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<Widget> sliverList = [];

    const numberOfItemsPerList = 10;
    List children = [];
    if (parsedJson.containsKey('children')) {
      children =
          updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    }

    List<Widget> list = [];

    /*bool includeTopOffset = TypeParser.parseBool(
      getValue(parsedJson, 'includeTopOffset', true, dynamicUIBuilderContext),
    )!;
    double extraTopOffset = TypeParser.parseDouble(
      getValue(parsedJson, 'extraTopOffset', 0, dynamicUIBuilderContext),
    )!;

    if (includeTopOffset) {
      list.add(SizedBox(
        //height: GlobalSettings().appBarHeight + extraTopOffset,
        height: extraTopOffset,
      ));
    }*/

    if (parsedJson.containsKey("appBar")) {
      sliverList
          .add(render(parsedJson, 'appBar', null, dynamicUIBuilderContext));
    } else {
      //Выправляет пространство под extendBodyBehindAppBar: true
      sliverList.add(const SliverAppBar(
        toolbarHeight: 0,
      ));
    }

    bool pullToRefresh = TypeParser.parseBool(
      getValue(parsedJson, 'pullToRefresh', true, dynamicUIBuilderContext),
    )!;
    if (pullToRefresh) {
      sliverList.add(
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 125,
          refreshIndicatorExtent: 125,
          onRefresh: () async {
            Future.delayed(const Duration(milliseconds: 700), () {
              //dynamicUIBuilderContext.dynamicPage.reload();
              dynamicUIBuilderContext.dynamicPage.safeReload();
            });
          },
        ),
      );
    }

    for (int i = 0; i < children.length; i++) {
      list.add(getRender(i, children, dynamicUIBuilderContext));
      if (i > 0 && i % numberOfItemsPerList == 0) {
        sliverList.add(getSliverList(list));
        list.clear();
      }
    }

    /*bool includeBottomOffset = TypeParser.parseBool(
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
    }*/

    if (parsedJson.containsKey("startFill")) {
      // SliverFillRemaining
      sliverList
          .add(render(parsedJson, 'startFill', null, dynamicUIBuilderContext));
    }

    if (list.isNotEmpty) {
      sliverList.add(getSliverList(list));
    }

    if (parsedJson.containsKey("endFill")) {
      //SliverFillRemaining
      sliverList
          .add(render(parsedJson, 'endFill', null, dynamicUIBuilderContext));
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
