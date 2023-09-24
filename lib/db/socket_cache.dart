import 'dart:convert';

import 'package:rjdu/db/data_source.dart';
import '../multi_invoke.dart';
import 'data.dart';
import 'data_getter.dart';

/*
* Замысел:
*   Если данные пришли из API по ним надо создать накопительный кеш, что бы обновить UI
*   Если данные пришли из синхронизации, надо немного повременить с обновлением UI (если есть накопительный кеш)
*
*   Накопительный кеш должен чиститься со временем
* */

class SocketCache {
  static final SocketCache _singleton = SocketCache._internal();

  factory SocketCache() {
    return _singleton;
  }

  Map<String, SyncTimer> cache = {};

  SocketCache._internal();

  void removeCache(String uuid) {
    cache.remove(uuid);
  }

  //Вызывается когда приходят новые сокет данные через синхронизацию
  void updateFromSync(Data fullData) {
    if (fullData.value.runtimeType == String) {
      fullData.value = json.decode(fullData.value);
    }
    if (cache.containsKey(fullData.uuid)) {
      SyncTimer syncTimer = cache[fullData.uuid]!;
      syncTimer.setNewData(fullData);
    } else {
      //Без задержек в перерисовку UI
      SyncTimer(fullData).notify();
    }
  }

  //Вызывается при установки новых значений в сокет данные через ApiInvoke
  void setDiff(Data diffData) {
    if (diffData.value.runtimeType == String) {
      diffData.value = json.decode(diffData.value);
    }
    if (!cache.containsKey(diffData.uuid)) {
      cache[diffData.uuid] = SyncTimer(diffData);
    }
    cache[diffData.uuid]!.setDiff(diffData);
  }

  void renderDBData(Data data) {
    removeCache(data.uuid);
    DataGetter.getDataJson(data.uuid, (dataUuid, dataDB) {
      data.value = dataDB;
      SyncTimer(data).notify();
    });
  }
}

class SyncTimer {
  final MultiInvoke multiInvoke = MultiInvoke(2000);
  late Data data;
  bool loadFromDb = false;
  Data? delayData;

  SyncTimer(Data diffData) {
    data = Data(diffData.uuid, diffData.value, diffData.type, diffData.parentUuid);
  }

  //Вызывается исключительно из процесса синхронизации
  void setNewData(Data syncData) {
    if (syncData.value.runtimeType == String) {
      syncData.value = json.decode(syncData.value);
    }
    delayData = syncData;
    delayAction();
  }

  void delayAction() {
    multiInvoke.invoke(() {
      SocketCache().removeCache(data.uuid); //Всегда сливаем кеш (решали задачу только быстрых прокликиваний)
      if (delayData != null) {
        data = delayData!;
        notify();
      }
    });
  }

  void notify() {
    DataSource().notifyBlockAsync(data, [], true);
  }

  void _mergeData(Data diffData) {
    //try {
    if (diffData.value != null) {
      Map<String, dynamic> fullData = data.value;
      for (MapEntry<String, dynamic> item in diffData.value.entries) {
        if (item.value == null) {
          fullData.remove(item.key);
        } else {
          fullData[item.key] = item.value;
        }
      }
      delayAction(); //Смещаем по времени перерисовку, если до этого пришла синхронизация
      notify();
    }
  }

  void setDiff(Data diffData) {
    if (loadFromDb == false) {
      // dataDiff.uuid - это всегда socketUuid
      DataGetter.getDataJson(data.uuid, (dataUuid, dataDB) {
        loadFromDb = true;
        data.value = dataDB;
        // Может быть наследованный сокетный кеш
        // Сокетный кеш всегда создаётся по socketUuid, но нас он может особо не интересовать
        // Нас интересует uuid по которому мы ждём обновления
        data.uuid = dataUuid;
        _mergeData(diffData);
      });
    } else {
      _mergeData(diffData);
    }
  }
}
