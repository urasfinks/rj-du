import 'bottom_tab.dart';

import 'bottom_tab_item.dart';
import 'dynamic_page.dart';

class NavigatorApp {
  static List<DynamicPage> allDynamicPage = [];
  static List<BottomTabItem> tab = [];
  static int selectedTab = 0;
  static Map<int, List<DynamicPage>> tabNavigator = {};
  static BottomTabState? bottomTabState;

  static void addNavigatorPage(DynamicPage dynamicPage, [int? indexTab]) {
    indexTab ??= selectedTab;
    if (!tabNavigator.containsKey(indexTab)) {
      tabNavigator[indexTab] = [];
    }
    if (!tabNavigator[indexTab]!.contains(dynamicPage)) {
      tabNavigator[indexTab]!.add(dynamicPage);
    }
  }

  static void removePage(DynamicPage dynamicPage) {
    allDynamicPage.remove(dynamicPage);
    if (tabNavigator.containsKey(selectedTab)) {
      tabNavigator[selectedTab]!.remove(dynamicPage);
    }
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
      dynamicPage.updateNotifier(uuid, data);
    }
  }

  static void reloadPage(String key, String value) {
    for (DynamicPage dynamicPage in allDynamicPage) {
      if (dynamicPage.arguments.containsKey(key) && dynamicPage.arguments[key] == value) {
        dynamicPage.reload();
      }
    }
  }
}
