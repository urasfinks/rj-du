import 'db/data.dart';
import 'data_type.dart';
import 'db/data_source.dart';
import 'util.dart';

class StateData {
  final Map<String, Data> map = {};

  void clear() {
    for (MapEntry<String, Data> item in map.entries) {
      Map<String, dynamic> empty = {};
      Data data = item.value;
      data.value = empty;
    }
  }

  Data getInstanceData(String? state, [Map<String, dynamic>? def]) {
    state ??= "main";
    if (!map.containsKey(state)) {
      Map<String, dynamic> data = def ?? {};
      Data d = Data(Util.uuid(), data, DataType.virtual, null);
      d.isStateData = true;
      map[state] = d;
    }
    return map[state]!;
  }

  bool isStateUuid(String uuid) {
    for (Data d in map.values) {
      if (d.uuid == uuid) {
        return true;
      }
    }
    return false;
  }

  void set(String? state, String key, dynamic value, [bool notifyDynamicPage = true]) {
    state ??= "main";
    Data data = getInstanceData(state);

    if (data.value[key] != value) {
      data.value[key] = value;
      DataSource().setData(data, notifyDynamicPage);
    }
  }

  void setMap(String? state, Map<String, dynamic> map, [bool notifyDynamicPage = true]) {
    state ??= "main";
    Data data = getInstanceData(state);
    bool change = false;
    for (MapEntry<String, dynamic> item in map.entries) {
      if (data.value[item.key] != item.value) {
        data.value[item.key] = item.value;
        change = true;
      }
    }
    if (change) {
      DataSource().setData(data, notifyDynamicPage);
    }
  }

  dynamic get(String? state, String key, dynamic defaultValue, [insertIfNotExist = false]) {
    state ??= "main";
    Data data = getInstanceData(state);

    Map<String, dynamic> map = data.value;
    if (map.containsKey(key)) {
      return map[key];
    } else {
      if (insertIfNotExist && !map.containsKey(key)) {
        map[key] = defaultValue;
        return map[key];
      } else {
        return defaultValue;
      }
    }
  }

  Map<String, dynamic> getAllData() {
    Map<String, dynamic> result = {};
    for (MapEntry<String, Data> item in map.entries) {
      result[item.key] = item.value.value;
    }
    return result;
  }
}
