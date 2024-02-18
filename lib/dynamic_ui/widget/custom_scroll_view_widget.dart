import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rjdu/data_sync.dart';
import 'package:rjdu/dynamic_ui/widget/scrollbar_widget.dart';
import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../type_parser.dart';
import '../widget/abstract_widget.dart';
import '../../util.dart';

class CustomScrollViewWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    //Получил ошибку зацикливания JSON при генерации includePageArgument в DynamicInvoke
    //Где-то в getRender ссылка на контекст проставляется и поехали по кругу
    parsedJson = Util.getMutableMap(parsedJson);
    List<Widget> sliverList = [];

    List children = [];
    if (parsedJson.containsKey("children")) {
      children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    }

    List<Widget> list = [];

    double extraTopOffset = TypeParser.parseDouble(
          getValue(parsedJson, "extraTopOffset", 0, dynamicUIBuilderContext),
        ) ??
        0;

    if (extraTopOffset > 0) {
      list.add(SizedBox(
        //height: GlobalSettings().appBarHeight + extraTopOffset,
        height: extraTopOffset,
      ));
    }

    if (parsedJson.containsKey("appBar")) {
      sliverList.add(render(parsedJson, "appBar", null, dynamicUIBuilderContext));
    } else {
      //Выправляет пространство под extendBodyBehindAppBar: true
      sliverList.add(const SliverAppBar(
        toolbarHeight: 0,
      ));
    }

    bool pullToRefresh = TypeParser.parseBool(
          getValue(parsedJson, "pullToRefresh", true, dynamicUIBuilderContext),
        ) ??
        true;
    if (pullToRefresh) {
      sliverList.add(
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 125,
          refreshIndicatorExtent: 125,
          onRefresh: () async {
            SyncResult syncResult = await DataSync().sync();
            if (syncResult.isSuccess()) {
              //Для того, что бы не было дёрганий перезагрузки страницы, даём свернуться pullToRefresh
              await Future.delayed(const Duration(milliseconds: 250), () {
                // Вижу что в последний раз удалили чистый reload и добавили без обновления состояний
                // Сейчас такая ситуация для TextField есть установленная data -> нажимаю [x] -> pullToRefresh
                // Данные больше не восстанавливатся, считаю это не хорошо
                dynamicUIBuilderContext.dynamicPage.reload(parsedJson["rebuild"] ?? true, "pullToRefresh");
              });
            }
          },
        ),
      );
    }

    List<Map<String, dynamic>> sliverGroup = [
      {"type": "list", "name": "main", "children": []}
    ];
    for (int i = 0; i < children.length; i++) {
      Map<String, dynamic> currentSliverGroupData = children[i]["SliverGroup"] ?? {"type": "list", "name": "main"};
      if (currentSliverGroupData["name"] == "main" && sliverGroup.last["name"] == "main") {
        sliverGroup.last["children"].add(children[i]);
      } else if (currentSliverGroupData["name"] == "main" && sliverGroup.last["name"] != "main") {
        sliverGroup.add({"type": "list", "name": "main", "children": []});
        sliverGroup.last["children"].add(children[i]);
      } else if (currentSliverGroupData["name"] != "main" &&
          sliverGroup.last["name"] == currentSliverGroupData["name"]) {
        sliverGroup.last["children"].add(children[i]);
      } else if (currentSliverGroupData["name"] != "main" &&
          sliverGroup.last["name"] != currentSliverGroupData["name"]) {
        currentSliverGroupData["children"] = [];
        sliverGroup.add(currentSliverGroupData);
        sliverGroup.last["children"].add(children[i]);
      }
    }
    for (Map<String, dynamic> item in sliverGroup) {
      List childrenSliverGroup = item["children"];
      if (childrenSliverGroup.isNotEmpty) {
        List<Widget> renderList = [];
        for (int i = 0; i < childrenSliverGroup.length; i++) {
          renderList.add(getRender(i, childrenSliverGroup, dynamicUIBuilderContext));
        }
        switch (item["type"]) {
          case "list":
            sliverList.add(getSliverList(renderList, getValue(parsedJson, "padding", null, dynamicUIBuilderContext)));
            break;
          case "grid":
            sliverList.add(getSliverGrid(renderList, item, dynamicUIBuilderContext));
            break;
        }
      }
    }

    double extraBottomOffset = TypeParser.parseDouble(
          getValue(parsedJson, "extraBottomOffset", 0, dynamicUIBuilderContext),
        ) ??
        0;
    bool isOpacityBottomNavigationBar = TypeParser.parseBool(
          getValue(parsedJson, "isOpacityBottomNavigationBar", true, dynamicUIBuilderContext),
        ) ??
        true;
    if (isOpacityBottomNavigationBar) {
      //Всегда добавляем с низу дополнительный блок из-за того, что прозрачный bottomBar
      list.add(SizedBox(
        height: GlobalSettings().bottomNavigationBarHeight + extraBottomOffset,
      ));
    }

    if (parsedJson.containsKey("startFill")) {
      // SliverFillRemaining
      sliverList.add(render(parsedJson, "startFill", null, dynamicUIBuilderContext));
    }

    if (list.isNotEmpty) {
      sliverList.add(getSliverList(list, getValue(parsedJson, "padding", null, dynamicUIBuilderContext)));
    }

    if (parsedJson.containsKey("endFill")) {
      //SliverFillRemaining
      sliverList.add(render(parsedJson, "endFill", null, dynamicUIBuilderContext));
    }
    bool scroll = TypeParser.parseBool(
          getValue(parsedJson, "scroll", true, dynamicUIBuilderContext),
        ) ??
        true;

    ScrollController controller;
    if (parsedJson.containsKey("saveScrollOffsetOnReload") && parsedJson["saveScrollOffsetOnReload"] == false) {
      controller = getController(parsedJson, "CustomScrollViewController", dynamicUIBuilderContext, () {
        return ScrollControllerWrap(ScrollController(), {});
      });
    } else {
      ScrollControllerWrap scrollControllerWrap =
          getControllerWrapFn(parsedJson, "CustomScrollViewController", dynamicUIBuilderContext, () {
        return ScrollControllerWrap(ScrollController(), {"offset": 0.0});
      }) as ScrollControllerWrap;
      scrollControllerWrap
          .setNewController(ScrollController(initialScrollOffset: scrollControllerWrap.stateControl["offset"]!));
      controller = scrollControllerWrap.controller;
      controller.addListener(() {
        scrollControllerWrap.stateControl["offset"] = controller.offset;
      });
    }

    return CustomScrollView(
      controller: controller,
      physics: scroll ? Util.getPhysics()! : const NeverScrollableScrollPhysics(),
      key: Util.getKey(),
      // primary: TypeParser.parseBool( //true нельзя использовать совместо с ScrollController
      //   getValue(parsedJson, "primary", true, dynamicUIBuilderContext),
      // ),
      reverse: TypeParser.parseBool(
        getValue(parsedJson, "reverse", false, dynamicUIBuilderContext),
      )!,
      scrollDirection: TypeParser.parseAxis(
        getValue(parsedJson, "scrollDirection", "vertical", dynamicUIBuilderContext)!,
      )!,
      //False по умолчанию, потому что высота самого ScrollView будет в размер всех блоков
      //Когда блоков не так много при скроле вниз будет скрывать содержимое не доходя до bottomTab
      shrinkWrap: TypeParser.parseBool(
        getValue(parsedJson, "shrinkWrap", false, dynamicUIBuilderContext),
      )!,
      cacheExtent: TypeParser.parseDouble(
        getValue(parsedJson, "cacheExtent", null, dynamicUIBuilderContext),
      ),
      slivers: sliverList,
    );
  }

  Widget getRender(int index, List children, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return render(children[index], null, null, dynamicUIBuilderContext);
  }

  dynamic getSliverList(List<Widget> defList, dynamic padding) {
    final List<Widget> list = [];
    list.addAll(defList);
    SliverList sliverList = SliverList(
      key: Util.getKey(),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => list[index],
        childCount: list.length,
      ),
    );
    if (padding != null) {
      return SliverPadding(
        padding: TypeParser.parseEdgeInsets(padding)!,
        sliver: sliverList,
      );
    } else {
      return sliverList;
    }
  }

  Widget getSliverGrid(
      List<Widget> defList, Map<String, dynamic> parsedJsonMutable, DynamicUIBuilderContext dynamicUIBuilderContext) {
    String type = getValue(parsedJsonMutable, "gridType", "count", dynamicUIBuilderContext);
    int crossAxisCount = TypeParser.parseInt(
          getValue(parsedJsonMutable, "crossAxisCount", 1, dynamicUIBuilderContext),
        ) ??
        1;
    double mainAxisSpacing = TypeParser.parseDouble(
          getValue(parsedJsonMutable, "mainAxisSpacing", 0.0, dynamicUIBuilderContext),
        ) ??
        0.0;
    double crossAxisSpacing = TypeParser.parseDouble(
          getValue(parsedJsonMutable, "crossAxisSpacing", 0.0, dynamicUIBuilderContext),
        ) ??
        0.0;
    double childAspectRatio = TypeParser.parseDouble(
          getValue(parsedJsonMutable, "childAspectRatio", 1.0, dynamicUIBuilderContext),
        ) ??
        1.0;

    double maxCrossAxisExtent = TypeParser.parseDouble(
          getValue(parsedJsonMutable, "maxCrossAxisExtent", 1.0, dynamicUIBuilderContext),
        ) ??
        1.0;

    EdgeInsets? padding = TypeParser.parseEdgeInsets(
      getValue(parsedJsonMutable, "padding", null, dynamicUIBuilderContext),
    );

    final List<Widget> list = [];
    list.addAll(defList);
    SliverGrid sliverGrid;
    switch (type) {
      case "extent":
        sliverGrid = SliverGrid.extent(
          key: Util.getKey(),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          maxCrossAxisExtent: maxCrossAxisExtent,
          children: list,
        );
        break;
      default:
        sliverGrid = SliverGrid.count(
          key: Util.getKey(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: list,
        );
        break;
    }
    if (padding != null) {
      return SliverPadding(
        padding: padding,
        sliver: sliverGrid,
      );
    } else {
      return sliverGrid;
    }
  }
}
