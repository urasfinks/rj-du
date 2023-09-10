class SystemNotify {
  static final SystemNotify _singleton = SystemNotify._internal();

  factory SystemNotify() {
    return _singleton;
  }

  SystemNotify._internal();

  Map<SystemNotifyEnum, List<Function(String state)>> notify = {};

  void emit(SystemNotifyEnum key, String value) {
    if (notify.containsKey(key)) {
      for (Function(String state) callback in notify[key]!) {
        callback(value);
      }
    }
  }

  void subscribe(SystemNotifyEnum key, Function(String state) callback) {
    if (!notify.containsKey(key)) {
      notify[key] = [];
    }
    if (!notify[key]!.contains(callback)) {
      notify[key]!.add(callback);
    }
  }

  void unsubscribe(SystemNotifyEnum key, Function(String state) callback) {
    if (notify.containsKey(key)) {
      notify[key]!.remove(callback);
    }
  }
}

enum SystemNotifyEnum {
  appLifecycleState,
  changeViewport,
  changeOrientation,
  changeBottomNavigationTab,
  openDynamicPage,
  changeThemeData
}
