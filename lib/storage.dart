import 'package:rjdu/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static final Storage _singleton = Storage._internal();
  SharedPreferences? prefs;
  Map<String, List<Function(String value)>> mapWatcher = {};

  factory Storage() {
    return _singleton;
  }

  Storage._internal();

  init() async {
    Util.p("Storage.init()");
    prefs = await SharedPreferences.getInstance();
  }

  void onChange(String key, String defaultValue, Function(String value) callback) {
    if (!mapWatcher.containsKey(key)) {
      mapWatcher[key] = [];
    }
    if (!mapWatcher[key]!.contains(callback)) {
      mapWatcher[key]!.add(callback);
    }
    callback(get(key, defaultValue));
  }

  String get(String key, String defaultValue) {
    String? result = prefs!.getString(key);
    return result ?? defaultValue;
  }

  String getByTemplate(String key, String defaultValue) {
    if (key == "uuid") {
      return "***";
    }
    return get(key, defaultValue);
  }

  void setMap(Map<String, dynamic> map, [bool updateIfExist = true]) {
    for (MapEntry<String, dynamic> item in map.entries) {
      set(item.key, item.value, updateIfExist);
    }
  }

  void set(String key, String value, [bool updateIfExist = true]) {
    if (updateIfExist || prefs!.getString(key) == null) {
      prefs!.setString(key, value);
      if (mapWatcher.containsKey(key)) {
        for (Function(String value) callback in mapWatcher[key]!) {
          callback(value);
        }
      }
    }
  }

  void remove(String key) {
    prefs!.remove(key);
    mapWatcher.remove(key);
  }
}
