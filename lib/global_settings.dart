import 'package:flutter/material.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/util.dart';

//# 16.09.2023 v10 - были исправления API сервера на синхронизацию

class GlobalSettings {
  bool debug = true;
  List<String> debugSql = [
    //"update data set is_remove_data = 1 where key_data = 'new_game' and is_remove_data = 0",
    //"SELECT type_data, max(revision_data) as max FRO:M data WHERE is_remove_data = 0 GROUP BY type_data",
    //"SELECT * from data where uuid_data = '604d1253-fc69-4e26-bc82-e4ad6f2a3702.mp3'"
    //"SELECT * from data where uuid_data = 'SerialState-s1'"
    //"SELECT * from data where key_data = 'SerialState' or key_data = 'LessState'"
    //"SELECT * from data where key_data = 'LessState'"
    //"SELECT * from data where key_data = 'less'"
    //"delete from data where key_data = 'SerialState' or key_data = 'LessState'"
    //"update data set meta_data = 'hello', revision_data = 0 where uuid_data = 'LessState-tst1'"
    //"select uuid_data, revision_data, lazy_sync_data from data where type_data = 'blob'"
  ];
  //String version = "v${Util.getTimestamp()}";
  String version = "v15";
  bool clearStorageOnUpdateVersion = false;
  String host = "https://e-humidor.ru:8453";
  String ws = "https://e-humidor.ru:8453";
  double appBarHeight = 56.0;
  double bottomNavigationBarHeight = 56.0;
  String orientation = ""; //landscape/portrait
  int debugStackTraceMaxFrames = 10;
  double barSeparatorOpacity = 0.04;
  bool bottomNavigationBar = true;
  FloatingActionButtonLocation floatingActionButtonLocation = FloatingActionButtonLocation.endFloat;

  static final GlobalSettings _singleton = GlobalSettings._internal();

  factory GlobalSettings() {
    return _singleton;
  }

  GlobalSettings._internal();

  void init() {
    SystemNotify().subscribe(SystemNotifyEnum.changeOrientation, (state) {
      orientation = state;
    });
    Util.p("GlobalSettings.init()");
  }

  void setHost(String host) {
    this.host = host;
  }

  String template(String key, String defaultValue) {
    switch (key) {
      case "host":
        return host;
      case "version":
        return version;
      case "ws":
        return ws;
      case "appBarHeight":
        return appBarHeight.toString();
      case "bottomNavigationBarHeight":
        return bottomNavigationBarHeight.toString();
      case "orientation":
        return orientation;
      default:
        return "";
    }
  }

  void setWs(String ws) {
    this.ws = ws;
  }
}
