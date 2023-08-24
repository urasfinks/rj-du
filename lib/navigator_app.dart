import 'bottom_tab.dart';
import 'bottom_tab_item.dart';
import 'dynamic_page.dart';

class NavigatorApp {
  static List<DynamicPage> allDynamicPage = [];
  static List<BottomTabItem> tab = [];
  static int selectedTab = 0;
  static Map<int, List<DynamicPage>> tabNavigator = {};
  static BottomTabState? bottomTabState;

  static void addPage(DynamicPage dynamicPage) {
    allDynamicPage.add(dynamicPage);
  }

  static DynamicPage? getPageByUuid(String uuid) {
    for (DynamicPage dynamicPage in allDynamicPage) {
      if (dynamicPage.uuid == uuid) {
        return dynamicPage;
      }
    }
    return null;
  }

  static void addNavigatorPage(DynamicPage dynamicPage, [int? indexTab]) {
    indexTab ??= selectedTab;
    dynamicPage.openInIndexTab = indexTab;
    if (!tabNavigator.containsKey(indexTab)) {
      tabNavigator[indexTab] = [];
    }
    if (!tabNavigator[indexTab]!.contains(dynamicPage)) {
      tabNavigator[indexTab]!.add(dynamicPage);
    }
  }

  static void removePage(DynamicPage dynamicPage) {
    Future.delayed(const Duration(seconds: 5), () {
      // Задержка сделана для того, что бы была возможность отработать destruct js для закрытой DynamicPage
      // Если сразу удалить, то getPageByUuid вернёт null, что приведёт к невозможности запустить
      // асинхронные вызовы SysInvoke
      // Для кейса при закрытии страницы - отобразить bottomNavigationBar, так как он мог был быть скрыт
      allDynamicPage.remove(dynamicPage);
    });

    if (tabNavigator.containsKey(selectedTab)) {
      tabNavigator[selectedTab]!.remove(dynamicPage);
    }
    dynamicPage.destructor();
  }

  static DynamicPage? getLast([int? indexTab]) {
    indexTab ??= selectedTab;
    return tabNavigator.containsKey(indexTab) ? tabNavigator[indexTab]!.last : null;
  }

  static bool isLast([int? indexTab]) {
    indexTab ??= selectedTab;
    return tabNavigator.containsKey(indexTab) ? (tabNavigator[indexTab]!.length == 1) : true;
  }

  static void updatePageNotifier(String uuid, Map<String, dynamic> data) {
    for (DynamicPage dynamicPage in allDynamicPage) {
      if (dynamicPage.isDispose == false) {
        dynamicPage.updateNotifier(uuid, data);
      }
    }
  }

  static void reloadPageByArguments(String key, String value) {
    for (DynamicPage dynamicPage in allDynamicPage) {
      if (dynamicPage.isDispose == false &&
          dynamicPage.arguments.containsKey(key) &&
          dynamicPage.arguments[key] == value) {
        dynamicPage.reload();
      }
    }
  }
}
