import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_invoke/handler/navigator_pop_handler.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/multi_invoke.dart';
import 'package:rjdu/theme_provider.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'dynamic_ui/dynamic_ui.dart';
import 'dynamic_ui/type_parser.dart';
import 'system_notify.dart';
import 'util.dart';
import 'bottom_tab_item.dart';
import 'dynamic_ui/dynamic_ui_builder_context.dart';
import 'navigator_app.dart';
import 'storage.dart';

class BottomTab extends StatefulWidget {
  final DynamicUIBuilderContext dynamicUIBuilderContext;

  const BottomTab(this.dynamicUIBuilderContext, {super.key});

  @override
  State<BottomTab> createState() => BottomTabState();
}

class BottomTabState extends State<BottomTab> with WidgetsBindingObserver, TickerProviderStateMixin {
  MultiInvoke multiDelay = MultiInvoke(500);

  @override
  void didChangePlatformBrightness() {
    multiDelay.invoke(() {
      String theme = View.of(context).platformDispatcher.platformBrightness.name;
      var currentTheme = Storage().get("theme", "");
      if (theme != currentTheme) {
        Storage().set("theme", theme);
        SystemNotify().emit(SystemNotifyEnum.changeThemeData, theme);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    SystemNotify().emit(SystemNotifyEnum.appLifecycleState, state.name);
  }

  @override
  void initState() {
    super.initState();
    NavigatorApp.bottomTabState = this;
    WidgetsBinding.instance.addObserver(this);
    SystemNotify().subscribe(SystemNotifyEnum.changeBottomNavigationTab, (state) {
      GlobalSettings().bottomNavigationBar = TypeParser.parseBool(state) ?? true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<BottomNavigationBarItem> getTabList() {
    List<BottomNavigationBarItem> result = [];
    for (BottomTabItem tabItem in NavigatorApp.tab) {
      result.add(tabItem.bottomNavigationBarItem);
    }
    return result;
  }

  List<Widget> getWidgetList() {
    List<Widget> result = [];
    for (BottomTabItem tabItem in NavigatorApp.tab) {
      result.add(tabItem.widget);
    }
    return result;
  }

  void selectTab(int index) {
    if (NavigatorApp.selectedTab != index) {
      setState(() {
        NavigatorApp.selectedTab = index;
        SystemNotify().emit(SystemNotifyEnum.changeViewport, "onChangeTab");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalSettings().appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight + 1;
    GlobalSettings().orientation = MediaQuery.of(context).orientation.name;
    // Ситуация: открывается keyboard -> reloadAllPage -> navigator_pop
    // В момент открытой keyboard: MediaQuery.of(context).padding.bottom = 0 а бео открытого keyboard = 34
    // Страница при перестроениении отображается не корректно
    // Пока захардкодим, посмотрим как проявляются будет

    GlobalSettings().bottomNavigationBarHeight = GlobalSettings().bottomNavigationBar ? (kBottomNavigationBarHeight + 34) : 0;

    int lastTimeClick = DateTime.now().millisecondsSinceEpoch;

    return Scaffold(
      extendBody: true,
      floatingActionButton: DynamicUI.render(
        Util.getMutableMap({
          "flutterType": "Notify",
          "link": {
            "template": "FloatingActionButton.json",
          },
          "context": {
            "key": "BottomTab",
            "data": {"template": {}}
          }
        }),
        null,
        null,
        widget.dynamicUIBuilderContext,
      ),
      floatingActionButtonLocation: GlobalSettings().floatingActionButtonLocation,
      bottomNavigationBar: Visibility(
        visible: GlobalSettings().bottomNavigationBar,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: ThemeProvider.blur, sigmaY: ThemeProvider.blur),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: TypeParser.parseColor("schema:secondary", context)!
                        .withOpacity(GlobalSettings().barSeparatorOpacity / 2),
                    width: 1.0,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                elevation: 0,
                showSelectedLabels: false,
                //Убираем подпись к выбранному табу
                showUnselectedLabels: false,
                //Убираем подписи к невыбранным табам
                items: getTabList(),
                currentIndex: NavigatorApp.selectedTab,
                onTap: (index) {
                  int nowTimeClick = DateTime.now().millisecondsSinceEpoch;
                  if (nowTimeClick - lastTimeClick < 200) {
                    DynamicInvoke().sysInvokeType(
                      NavigatorPopHandler,
                      {"tab": index, "toBegin": true},
                      widget.dynamicUIBuilderContext,
                    );
                  }
                  lastTimeClick = nowTimeClick;
                  selectTab(index);
                },
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: NavigatorApp.selectedTab,
        children: getWidgetList(),
      ),
    );
  }
}
