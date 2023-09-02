class SubscriberObject {
  final Map<String, dynamic> link;
  final Map<String, dynamic> _data = {};
  bool isUpdated = true;

  SubscriberObject(this.link);

  Map<String, dynamic> get(){
    isUpdated = false;
    return _data;
  }

  set(String uuid, Map<String, dynamic> newData) {
    // Тут немного вывернуто получилось, реальные uuid лежат в значениях словаря link
    // А обновлять контейнеры надо по псевдонимам
    for (MapEntry<String, dynamic> item in link.entries) {
      if (uuid == item.value) {
        _data[item.key] = newData;
        isUpdated = true;
        break;
      }
    }
  }
}
