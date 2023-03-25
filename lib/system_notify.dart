class SystemNotify {
  static final SystemNotify _singleton = SystemNotify._internal();

  factory SystemNotify() {
    return _singleton;
  }

  SystemNotify._internal();

  Map<SystemNotifyEnum, List<Function(String state)>> notify = {};

  void emit(SystemNotifyEnum key, String value) {
    if (!notify.containsKey(key)) {
      notify[key] = [];
    }
    for (Function(String state) callback in notify[key]!) {
      callback(value);
    }
  }

  void listen(SystemNotifyEnum key, Function(String state) callback) {
    if (!notify.containsKey(key)) {
      notify[key] = [];
    }
    notify[key]!.add(callback);
  }
}

enum SystemNotifyEnum {
  appLifecycleState,
  changeTabOrHistoryPop,
}
