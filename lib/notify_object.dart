class SubscriberObject {
  final Map<String, dynamic> link;
  Map<String, dynamic> data = {};

  SubscriberObject(this.link);

  set(String uuid, Map<String, dynamic> newData) {
    for (MapEntry<String, dynamic> item in link.entries) {
      if (uuid == item.value) {
        data[item.key] = newData;
        break;
      }
    }
  }
}
