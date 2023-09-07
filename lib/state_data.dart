import 'db/data.dart';
import 'data_type.dart';
import 'db/data_source.dart';
import 'util.dart';

class StateData {
  final Map<String, Data> map = {};
  final Map<String, Map<String, dynamic>?> defMap = {};

  void clear() {
    // Проблема частичной очистки только value выглядит так:
    // При получении состояния мы устанавливаем дефолтное значение
    // Дефолтное значение устанавливается только в том случаи если в map нет по этому ключу ничего
    // при попытки получения у нас дефолтное значение просто исчезает
    // Мы в коде опираемся на дефолтные ключи и падаем на Null
    // map.clear();
    // Походу мы не имеем права просто делать map.clear так как на uuid данных уже были подписки и мы тупо всё похерим

    for (MapEntry<String, Data> item in map.entries) {
      Map<String, dynamic> def = {};
      if (defMap.containsKey(item.key)) {
        def.addAll(defMap[item.key]!);
      }
      Data data = item.value;
      data.value = def;
    }
  }

  Data getInstanceData(String? state, [Map<String, dynamic>? def]) {
    state ??= "main";
    if (!map.containsKey(state)) {
      Map<String, dynamic> data = def ?? {};
      Data d = Data(Util.uuid(), data, DataType.virtual, null);
      d.isStateData = true;
      map[state] = d;
      if (def != null) {
        defMap[state] = {};
        defMap[state]!.addAll(def);
      }
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

    if (data.value[key] == null || data.value[key] != value) {
      data.value[key] = value;
      Util.p("StateData.set(state:$state, key:$key, value: $value, notify: $notifyDynamicPage)");
      DataSource().setData(data, notifyDynamicPage);
    }
  }

  void setMap(String? state, Map<String, dynamic> map, [bool notifyDynamicPage = true]) {
    state ??= "main";
    Data data = getInstanceData(state);
    bool change = false;
    // Если мы используем функцию AbstractWidget.getStateControl
    // Мы получаем ссылку на Data.value
    // Если мы поменяем данные по ссылке в widget, то тут мы никогда не сможем понять какие поля были обновлены
    // По этому если ссылки одинаковые - делаем вид, что, что-то поменялось. Ну вот так вот!)
    if (data.value == map) {
      change = true;
    } else {
      for (MapEntry<String, dynamic> item in map.entries) {
        if (data.value[item.key] != item.value) {
          data.value[item.key] = item.value;
          change = true;
        }
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
