import 'package:flutter/foundation.dart';

class GlobalSettings {
  bool debug = true;
  String version = "v3";
  String host = "https://e-humidor.ru:8453";

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
}
