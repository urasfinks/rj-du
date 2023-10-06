import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rjdu/data_sync.dart';
import 'package:rjdu/db/socket_cache.dart';
import 'package:rjdu/dynamic_invoke/handler/alert_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../data_type.dart';
import '../../http_client.dart';
import '../global_settings.dart';
import '../multi_invoke.dart';
import '../navigator_app.dart';
import '../subscribe_reload_group.dart';
import '../util.dart';
import 'data_getter.dart';
import 'data_migration.dart';
import 'getter_task.dart';
import 'data.dart';

class DataSource {
  static final DataSource _singleton = DataSource._internal();

  factory DataSource() {
    return _singleton;
  }

  DataSource._internal();

  bool isInit = false;
  List<dynamic> list = [];
  List<DataType> notJsonList = [DataType.js, DataType.any, DataType.blob, DataType.blobRSync];
  late Database db;
  Map<String, List<Function(String uuid, Map<String, dynamic>? data)>> listener = {};
  DataMigration dataMigration = DataMigration();

  init() async {
    Util.p("DataSource.init()");
    final directory = await getApplicationDocumentsDirectory();
    db = await openDatabase("${directory.path}/mister-craft-1.sqlite3", version: 1);
    await dataMigration.init();
    isInit = true;
    flushQueue();
    if (GlobalSettings().debug && GlobalSettings().debugSql.isNotEmpty) {
      for (String sql in GlobalSettings().debugSql) {
        DataGetter.debug(sql);
      }
    }
  }

  bool isJsonDataType(DataType? dataType) {
    if (dataType == null) {
      return false;
    }
    return !notJsonList.contains(dataType);
  }

  void flushQueue() {
    var count = 0;
    if (isInit) {
      while (list.isNotEmpty) {
        var remove = list.first;
        if (remove.runtimeType == Data) {
          Data dataInsertion = remove as Data;
          setData(dataInsertion);
        } else if (remove.runtimeType == GetterTask) {
          get(remove.uuid, remove.handler);
        }
        list.remove(remove);
        count++;
      }
    }
    Util.p("flushQueue complete: $count");
  }

  void set(String uuid, dynamic value, DataType type, [String? key, String? parent, bool updateIfExist = true]) {
    Data data = Data(uuid, value, type, parent);
    data.key = key;
    data.updateIfExist = updateIfExist;
    setData(data);
  }

  void setData(Data data, [bool notifyDynamicPage = true]) {
    groupMultiUpdate(data);
    List<String> transaction = [];
    if (isInit) {
      transaction.add("1 is init");
      if (data.type == DataType.virtual) {
        //Состояние страницы (для виртуалок beforeSync не актуален)
        setDataVirtual(data, transaction, notifyDynamicPage);
      } else if (data.type == DataType.socket && data.beforeSync == false) {
        // Отправим сокетные данные на сервере
        setDataSocket(data, transaction, notifyDynamicPage);
      } else {
        //Если beforeSync = true, попадём сюда!
        setDataStandard(data, transaction, notifyDynamicPage);
      }
    } else {
      transaction.add("10 not init");
      list.add(data);
      printTransaction(data, transaction);
    }
  }

  final MultiInvoke multiInvoke = MultiInvoke(1000);

  Map<SubscribeReloadGroup, List<String>> mapMultiUpdate = {
    SubscribeReloadGroup.key: [],
    SubscribeReloadGroup.parentUuid: [],
    SubscribeReloadGroup.uuid: [],
  };

  void groupMultiUpdate(Data data) {
    //Группируем множественные обновления по подписке для единоразового обновления
    mapMultiUpdate[SubscribeReloadGroup.uuid]!.add(data.uuid);
    if (data.parentUuid != null) {
      mapMultiUpdate[SubscribeReloadGroup.parentUuid]!.add(data.parentUuid!);
    }
    if (data.key != null) {
      mapMultiUpdate[SubscribeReloadGroup.key]!.add(data.key!);
    }
    multiInvoke.invoke(() {
      NavigatorApp.reloadPageBySubscription(mapMultiUpdate, true);
      for (MapEntry<SubscribeReloadGroup, List<String>> item in mapMultiUpdate.entries) {
        item.value.clear();
      }
    });
  }

  void printTransaction(Data data, List<String> transaction) {
    if (data.debugTransaction) {
      Util.p("setData: ${data.uuid} transaction: $transaction");
    }
  }

  void setDataStandard(Data data, List<String> transaction, bool notifyDynamicPage) {
    transaction.add("5 saveToDB");
    db.rawQuery("SELECT * FROM data where uuid_data = ?", [data.uuid]).then((resultSet) {
      bool notify = false;
      if (data.isRemove == 1) {
        transaction.add("5.1 remove");
        delete(data);
        //notify = true; //Когда удаляются данные, нечего посылать в notifyBlockAsync, value уже пустое
        //Для фиксации изменений используйте DynamicPage._subscribedOnReload (косвенные взаимосвязи в обход Notify)
      } else if (resultSet.isEmpty) {
        transaction.add("6 result is empty > insert");
        insert(data);
        notify = true;
        // С сокетными данными мы пришли сюда, потому что был установлен beforeSync
        // Но данных в локальной БД нет, а на сервере данные не могут появится самостоятельно)
        // Следоватлеьно у нас ни что иное как инсерт, и в случаи сокета - мы должны его пролить в удалённую БД
        if (data.type == DataType.socket) {
          // После того как мы вставили сокетные данные
          // Надо запустить синхронизацию
          // Что бы эта запись на сервер уползла
          transaction.add("6.1 DataSync().sync()");
          DataSync().sync();
        }
      } else if (data.updateIfExist == true) {
        transaction.add("7 result not empty > update");
        //resultSet.first["value_data"] != dataString
        // данные надо иногда обновлять не только потому что изменились
        // сами данные, бывает что надо бновить флаг удаления или ревизию
        updateNullable(data, resultSet.first);
        update(data);
        notify = true;
      } else {
        transaction.add("8 NOTHING!");
      }
      if (data.isRemove == 0 && data.type == DataType.socket && data.beforeSync == true) {
        SocketCache().updateFromSync(data);
      } else if (notify) {
        notifyBlockAsync(data, transaction, notifyDynamicPage);
      } else {
        printTransaction(data, transaction);
      }
    }).onError((error, stackTrace) {
      Util.printStackTrace("setDataStandard()", error, stackTrace);
    });
  }

  void notifyBlockAsync(Data data, List<String> transaction, bool notifyDynamicPage) {
    if (notifyDynamicPage) {
      transaction.add("3 notifyBlock()");
      //Что бы не было коллизии setState или marketRebuild во время build
      Util.asyncInvoke((args) {
        try {
          notifyBlock(args);
        } catch (e, stacktrace) {
          Util.printStackTrace("DataSource.notifyBlockAsync() args: $args", e, stacktrace);
        }
      }, data);
    }
    printTransaction(data, transaction);
  }

  void setDataVirtual(Data data, List<String> transaction, bool notifyDynamicPage) {
    transaction.add("2 is virtual");
    notifyBlockAsync(data, transaction, notifyDynamicPage);
  }

  void setDataSocket(Data diffData, List<String> transaction, bool notifyDynamicPage) {
    // Обновление сокетных данных не должно обновлять локальную БД
    // diffData.uuid - это Primary uuid, если мы в режиме parent надо вытащить локальный uuid
    transaction.add("4 update socket data");
    if (notifyDynamicPage) {
      SocketCache().setDiff(diffData);
    }
    sendDataSocket(diffData, notifyDynamicPage);
    printTransaction(diffData, transaction);
  }

  void sendDataSocket(Data data, bool notifyDynamicPage) async {
    Map<String, dynamic> postData = {"uuid_data": data.uuid, "data": data.value};
    try {
      Response response = await Util.asyncInvokeIsolate((args) {
        return HttpClient.post("${args["host"]}/SocketUpdate", args["body"], args["headers"]);
      }, {
        "headers": HttpClient.upgradeHeadersAuthorization({}),
        "body": postData,
        "host": GlobalSettings().host,
      });
      if (response.statusCode == 200) {
      } else {
        AlertHandler.alertSimple("Данные не зафиксированы на сервере");
        Future.delayed(const Duration(seconds: 1), () {
          SocketCache().renderDBData(data.uuid);
        });
      }
      // Util.p(
      //     "DataSource.sendSocketUpdate() Response Code: ${response.statusCode}; Body: ${response.body}; Headers: ${response.headers}");
    } catch (e, stacktrace) {
      AlertHandler.alertSimple("Данные не зафиксированы на сервере");
      Future.delayed(const Duration(seconds: 1), () {
        SocketCache().renderDBData(data.uuid);
      });
      Util.printStackTrace("DataSource.sendDataSocket() data: $data", e, stacktrace);
    }

    // тут не будем вызывать синхронизацию данных,
    // так как событие на синхронизацию должно прийти по сокету
    // После http запроса
  }

  void updateNullable(Data curData, dynamic dbResult) {
    if (curData.onUpdateOverlayNullField) {
      curData.value ??= dbResult["value_data"];
      curData.parentUuid ??= dbResult["parent_uuid_data"];
      curData.key ??= dbResult["key_data"];
      curData.dateAdd ??= dbResult["date_add_data"];
      curData.dateUpdate ??= dbResult["date_update_data"];
      curData.revision ??= dbResult["revision_data"];
      curData.isRemove ??= dbResult["is_remove_data"];
    }
  }

  void update(Data curData) {
    if (curData.onUpdateResetRevision && curData.type.name.endsWith("RSync")) {
      curData.revision = 0;
    }
    String dataString = curData.value.runtimeType != String ? json.encode(curData.value) : curData.value;
    db.rawUpdate(
      'UPDATE data SET value_data = ?, type_data = ?, parent_uuid_data = ?, key_data = ?, date_add_data = ?, date_update_data = ?, revision_data = ?, is_remove_data = ? WHERE uuid_data = ?',
      [
        dataString,
        curData.type.name,
        curData.parentUuid,
        curData.key,
        curData.dateAdd,
        curData.dateUpdate,
        curData.revision,
        curData.isRemove,
        curData.uuid,
      ],
    ).then((value) {
      if (curData.onPersist != null) {
        Function.apply(curData.onPersist!, null);
      }
    }).onError((error, stackTrace) {
      Util.printStackTrace("DataSource.update()", error, stackTrace);
    });
  }

  void insert(Data curData) {
    db.rawInsert(
      'INSERT INTO data (uuid_data, value_data, type_data, parent_uuid_data, key_data, date_add_data, date_update_data, revision_data, is_remove_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        curData.uuid,
        curData.value.runtimeType != String ? json.encode(curData.value) : curData.value,
        curData.type.name,
        curData.parentUuid,
        curData.key,
        curData.dateAdd ??= Util.getTimestampMillis(),
        curData.dateUpdate,
        curData.revision ??= 0,
        curData.isRemove ??= 0,
      ],
    ).then((value) {
      if (curData.onPersist != null) {
        Function.apply(curData.onPersist!, null);
      }
    }).onError((error, stackTrace) {
      Util.printStackTrace("DataSource.insert()", error, stackTrace);
    });
  }

  void delete(Data curData) {
    // Будучи в здравии))) Я отдаю отчёт, что удаляя записи из локальной БД может быть фон, что сервер при синхронизации
    // Постоянно будет отдавать их, так как getMaxRevisionByType будет отдавать ревизии меньшии по значению чем удаление
    // А сервер будет говорит, вот смотри тут удаление произошло
    // Так будет продолжаться до тех пор, пока не появится свежая ревизия из этого типа
    // В БД что бы не расходовать место, надо уничтожать данные, но удалять из удалённой БД мы не имеем права
    // Так как если данные были на нескольких устройств, и одно устройство используется реже, то может так получится,
    // Что если на сервере удалить данные, то на второе устройство не дойдёт ревизия удаления и у нас получится рассинхрон
    db.rawInsert(
      'DELETE FROM data WHERE uuid_data = ?',
      [curData.uuid],
    ).then((value) {
      if (curData.onPersist != null) {
        Function.apply(curData.onPersist!, null);
      }
    }).onError((error, stackTrace) {
      Util.printStackTrace("DataSource.insert()", error, stackTrace);
    });
  }

  void notifyBlock(Data curData) {
    Map<String, dynamic> runtimeData = {};
    if (curData.value.runtimeType == String && isJsonDataType(curData.type)) {
      runtimeData = json.decode(curData.value);
    } else if (curData.value.runtimeType != String) {
      if (curData.value.runtimeType.toString().contains("Map<dynamic, dynamic>")) {
        runtimeData = Util.getMutableMap(curData.value);
      } else {
        runtimeData = curData.value;
      }
    } else {
      runtimeData = {curData.type.name: curData.value};
    }
    // Оповещение для перестройки страниц ранее было только для json форматов
    // Сейчас я обновляю аватар с типом blobRSync и мне как бы надо получить уведомление, что аватар был заменён
    // Пока закоментирую проверку на json тип, не знаю для чего он тут
    //if (isJsonDataType(curData.type)) {
    NavigatorApp.updatePageNotifier(curData.uuid, runtimeData);
    //}
    //Оповещение программных компонентов, кто подписался на onChange
    if (listener.containsKey(curData.uuid)) {
      for (Function(String uuid, Map<String, dynamic>? data) callback in listener[curData.uuid]!) {
        callback(curData.uuid, runtimeData);
      }
    }
  }

  void get(String uuid, Function(String uuid, Map<String, dynamic>? data) handler) {
    if (isInit) {
      db.rawQuery("SELECT * FROM data where uuid_data = ?", [uuid]).then((resultSet) {
        if (resultSet.isNotEmpty && resultSet.first["value_data"] != null) {
          DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first["type_data"] as String?);
          if (isJsonDataType(dataTypeResult)) {
            //handler(await Util.asyncInvokeIsolate((arg) => json.decode(arg), resultSet.first["value_data"]));
            handler(resultSet.first["uuid_data"] as String, json.decode(resultSet.first["value_data"] as String));
          } else {
            handler(resultSet.first["uuid_data"] as String, {dataTypeResult.name: resultSet.first["value_data"]});
          }
        } else {
          handler(uuid, null);
        }
      }).onError((error, stackTrace) {
        Util.printStackTrace("DataSource.get()", error, stackTrace);
      });
    } else {
      list.add(GetterTask(uuid, handler));
    }
  }

  void subscribe(String uuid, Function(String uuid, Map<String, dynamic>? data) callback) {
    get(uuid, callback);
    if (!listener.containsKey(uuid)) {
      listener[uuid] = [];
    }
    if (!listener[uuid]!.contains(callback)) {
      listener[uuid]!.add(callback);
    }
  }

  void unsubscribe(Function(String uuid, Map<String, dynamic>? data) callback) {
    List<String> clear = [];
    for (MapEntry<String, List<Function(String uuid, Map<String, dynamic>? data)>> item in listener.entries) {
      if (item.value.contains(callback)) {
        item.value.remove(callback);
      }
      if (item.value.isEmpty) {
        clear.add(item.key);
      }
    }
    for (String key in clear) {
      listener.remove(key);
    }
  }
}
