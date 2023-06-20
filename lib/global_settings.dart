import 'package:flutter/foundation.dart';

class GlobalSettings {
  bool debug = true;
  String version = "v4";
  String host = "https://e-humidor.ru:8453";
  String ws = "https://e-humidor.ru:8453";
  double appBarHeight = 56.0;
  double bottomNavigationBarHeight = 56.0;

  static final GlobalSettings _singleton = GlobalSettings._internal();

  factory GlobalSettings() {
    return _singleton;
  }

  GlobalSettings._internal();

  void init() {
    if (kDebugMode) {
      print("GlobalSettings.init()");
    }
  }

  void setHost(String host) {
    this.host = host;
  }

  void setWs(String ws) {
    this.ws = ws;
  }
}
