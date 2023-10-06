import 'dart:async';
import 'dart:convert';

import 'package:rjdu/data_type.dart';
import 'package:rjdu/db/data_source.dart';
import '../multi_invoke.dart';
import 'data.dart';
import 'data_getter.dart';

/*
* Замысел:
*   Если данные пришли из API по ним надо создать накопительный кеш, что бы обновить UI
*   Если данные пришли из синхронизации, надо немного повременить с обновлением UI (если есть накопительный кеш)
*
*   Накопительный кеш должен чиститься когда приходят данные из синхронизации вступают в силу
* */

class SocketCache {
  static final SocketCache _singleton = SocketCache._internal();

  factory SocketCache() {
    return _singleton;
  }

  Map<String, SyncTimer> cache = {};

  SocketCache._internal();

  void remove(String uuid) {
    cache.remove(uuid);
  }

  //Вызывается когда приходят обновление сокетных данных через синхронизацию
  void updateFromSync(Data fullData) {
    //После синхронизации fullData.uuid будет всегда локальный
    if (fullData.value.runtimeType == String) {
      fullData.value = json.decode(fullData.value);
    }
    if (!cache.containsKey(fullData.uuid)) {
      //Если нет кеша, сразу обновляем UI + в кеш ничего не заносим, так как это может породить задержки
      SyncTimer.fromData(fullData).notify();
    } else {
      //Если кеш есть, обновляем с задержкой
      cache[fullData.uuid]!.setNewData(fullData.value);
    }
  }

  //Вызывается при установки новых значений в сокет данные через ApiInvoke
  Future<void> setDiff(Data diffData) async {
    //diffData.uuid всегда будет primary socket uuid, а нам нужен локальный
    SyncTimer syncTimer = await SyncTimer.fromDB(diffData.uuid);
    if (diffData.value.runtimeType == String) {
      diffData.value = json.decode(diffData.value);
    }
    if (!cache.containsKey(syncTimer.data.uuid)) {
      cache[syncTimer.data.uuid] = syncTimer;
    }
    cache[syncTimer.data.uuid]!.setDiff(diffData.value);
  }

  //В случае ошибок
  void renderDBData(String uuid) async {
    remove(uuid);
    SyncTimer syncTimer = await SyncTimer.fromDB(uuid);
    syncTimer.notify();
  }
}

class SyncTimer {
  static Future<SyncTimer> fromDB(String uuid) async {
    var completer = Completer<SyncTimer>();
    DataGetter.getDataJson(uuid, (dataUuid, dataDB) {
      SyncTimer syncTimer = SyncTimer();
      syncTimer.data = Data(dataUuid, dataDB, DataType.socket, null);
      completer.complete(syncTimer);
    });
    return completer.future;
  }

  static SyncTimer fromData(Data data) {
    SyncTimer syncTimer = SyncTimer();
    syncTimer.data = data;
    return syncTimer;
  }

  final MultiInvoke multiInvoke = MultiInvoke(2000);
  late Data data;

  //Вызывается исключительно из процесса синхронизации
  void setNewData(Map<String, dynamic> syncDataValue) {
    multiInvoke.invoke(() {
      data.value = syncDataValue;
      notify();
      // Если настал момент обновления данных через синхронизацию, зачит всё то можно было протыкано в UI
      // Можем смело удалят времянку
      SocketCache().remove(data.uuid);
    });
  }

  void notify() {
    DataSource().notifyBlockAsync(data, [], true);
  }

  //Это должно вызываться из ApiInvoke
  void setDiff(Map<String, dynamic>? diffDataValue) {
    multiInvoke.stop(); //Если пришли данные с сервера и ждут обновления, останавливаем, прийдёт новая синхронизация
    if (diffDataValue != null) {
      Map<String, dynamic> fullData = data.value;
      for (MapEntry<String, dynamic> item in diffDataValue.entries) {
        if (item.value == null) {
          fullData.remove(item.key);
        } else {
          fullData[item.key] = item.value;
        }
      }
      notify();
    }
  }
}
