import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rjdu/assets_data.dart';
import 'package:rjdu/data_sync.dart';
import 'package:rjdu/db/socket_cache.dart';
import 'package:rjdu/dynamic_invoke/handler/alert_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../data_type.dart';
import '../../http_client.dart';
import '../global_settings.dart';
import '../multi_invoke.dart';
import '../navigator_app.dart';
import '../storage.dart';
import '../subscribe_reload_group.dart';
import '../util.dart';
import 'data_getter.dart';
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

  init() async {
    Util.p(
        "DataSource.init() ${GlobalSettings().version}; updateApplication = ${Storage().isUpdateApplicationVersion()}");
    final directory = await getApplicationDocumentsDirectory();
    db = await openDatabase("${directory.path}/mister-craft-1.sqlite3", version: 1);
    if (Storage().isUpdateApplicationVersion()) {
      await _sqlExecute([
        "db/drop/2023-01-31.sql",
        "db/migration/2023-01-29.sql",
      ]);
      Util.p("Migration complete");
    }
    isInit = true;
    //Если обновилось приложение или мы в режиме отладки - синхронизируем содержимое assets в локальной БД
    if (Storage().isUpdateApplicationVersion() || GlobalSettings().debug) {
      for (AssetsDataItem assetsDataItem in AssetsData().list) {
        await DataSource().set(
          assetsDataItem.name,
          assetsDataItem.data,
          assetsDataItem.type,
          null,
          null,
          true,
        );
      }
      Util.p("DataSource().set() ${AssetsData().list.length} assets");
    }
    flushQueue();
    if (GlobalSettings().debug && GlobalSettings().debugSql.isNotEmpty) {
      for (String sql in GlobalSettings().debugSql) {
        DataGetter.debug(sql);
      }
    }
  }

  Future<void> _sqlExecute(List<String> files) async {
    for (String file in files) {
      if (file.trim() == "") {
        continue;
      }
      Util.p("Migration: $file");
      String migration = await AssetsData().getFileContent("packages/rjdu/lib/assets/$file");
      //sqflite не умеет выполнять скрипт из нескольких запросов (как не странно)
      List<String> split = migration.split(";");
      for (String query in split) {
        query = query.trim();
        if (query.isNotEmpty) {
          DataSource().db.execute(query).onError((error, stackTrace) {
            Util.log("DataMigration._sqlExecute(); Error: $error", stackTrace: stackTrace, type: "error");
          });
        }
      }
    }
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

  set(String uuid, dynamic value, DataType type,
      [String? key, String? parent, bool updateIfExist = true, String? meta]) async {
    Data data = Data(uuid, value, type, parent);
    data.key = key;
    data.meta = meta;
    data.updateIfExist = updateIfExist;
    await setData(data);
  }

  Future<bool> setData(Data data, [bool notifyDynamicPage = true]) async {
    bool result = true;
    try {
      List<String> transaction = [];
      if (isInit) {
        groupMultiUpdate(data);
        transaction.add("1 is init");
        if (data.type == DataType.virtual) {
          //Состояние страницы (для виртуалок beforeSync не актуален)
          setDataVirtual(data, transaction, notifyDynamicPage);
        } else if (data.type == DataType.socket && data.beforeSync == false) {
          // Отправим сокетные данные на сервере
          // Так как транзация разорванная onPersist может лишь сказать о том, что данные мы доставили до сервера
          // Данные залитают в БД после стягивания их через синхронизацию, которая вызывается у всех сокет потребителей
          result = await setDataSocket(data, transaction, notifyDynamicPage);
        } else {
          //Если DataType.socket и beforeSync = true, попадём сюда! это ХАК для сокетных данных
          result = await setDataStandard(data, transaction, notifyDynamicPage);
        }
      } else {
        transaction.add("10 not init");
        list.add(data);
        printTransaction(data, transaction);
      }
    } catch (error, stackTrace) {
      result = false;
      Util.log("DataSource.setData() $data; Error: $error", stackTrace: stackTrace, type: "error");
    }
    return result;
  }

  final MultiInvoke multiInvoke = MultiInvoke(1000);

  Map<SubscribeReloadGroup, List<String>> mapMultiUpdate = {
    SubscribeReloadGroup.key: [],
    SubscribeReloadGroup.parentUuid: [],
    SubscribeReloadGroup.uuid: [],
  };

  void groupMultiUpdate(Data data) {
    if (data.notify) {
      //Группируем множественные обновления по подписке для единоразового обновления
      if (!mapMultiUpdate[SubscribeReloadGroup.uuid]!.contains(data.uuid)) {
        mapMultiUpdate[SubscribeReloadGroup.uuid]!.add(data.uuid);
      }
      if (data.parentUuid != null) {
        if (!mapMultiUpdate[SubscribeReloadGroup.parentUuid]!.contains(data.parentUuid!)) {
          mapMultiUpdate[SubscribeReloadGroup.parentUuid]!.add(data.parentUuid!);
        }
      }
      if (data.key != null) {
        if (!mapMultiUpdate[SubscribeReloadGroup.key]!.contains(data.key!)) {
          mapMultiUpdate[SubscribeReloadGroup.key]!.add(data.key!);
        }
      }
      multiInvoke.invoke(() {
        NavigatorApp.reloadPageBySubscription(mapMultiUpdate, true);
        for (MapEntry<SubscribeReloadGroup, List<String>> item in mapMultiUpdate.entries) {
          item.value.clear();
        }
      });
    }
  }

  void printTransaction(Data data, List<String> transaction) {
    if (data.debugTransaction) {
      Util.p("setData: ${data.uuid} transaction: $transaction");
    }
  }

  Future<bool> setDataStandard(Data data, List<String> transaction, bool notifyDynamicPage) async {
    bool result = true;
    try {
      transaction.add("5 saveToDB");
      dynamic resultSet = await db.rawQuery("SELECT * FROM data where uuid_data = ?", [data.uuid]);
      bool notify = false;
      if (data.isRemove == 1) {
        transaction.add("5.1 remove");
        result = await delete(data);
        //notify = true; //Когда удаляются данные, нечего посылать в notifyBlockAsync, value уже пустое
        //Для фиксации изменений используйте DynamicPage._subscribedOnReload (косвенные взаимосвязи в обход Notify)
      } else if (resultSet.isEmpty) {
        transaction.add("6 result is empty > insert");
        result = await insert(data);
        notify = true;
        // С сокетными данными мы пришли сюда, потому что был установлен beforeSync=true
        // Но данных в локальной БД нет, а на сервере данные не могут появится самостоятельно)
        // Следоватлеьно у нас ни что иное как инсерт, и в случаи сокета - мы должны его пролить в удалённую БД
        if (data.type == DataType.socket && (data.revision == null || data.revision == 0)) {
          // После того как мы вставили сокетные данные
          // Надо запустить синхронизацию
          // Что бы эта запись на сервер уползла
          transaction.add("6.1 DataSync().sync()");
          SyncResult syncResult = await DataSync().sync();
          if (!syncResult.isSuccess()) {
            result = false;
          }
        }
      } else if (data.updateIfExist == true) {
        transaction.add("7 result not empty > update");
        //resultSet.first["value_data"] != dataString
        // данные надо иногда обновлять не только потому что изменились
        // сами данные, бывает что надо бновить флаг удаления или ревизию
        updateNullable(data, resultSet.first);
        updateOverlayJsonValue(data, resultSet.first);
        result = await updateDataSource(data);
        notify = true;
        //Сокетные данные не могут обновляться, поэтому не предполагаем вызова синхронизации
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
    } catch (error, stackTrace) {
      result = false;
      Util.log("setDataStandard(); Error: $error", stackTrace: stackTrace, type: "error");
    }
    return result;
  }

  void notifyBlockAsync(Data data, List<String> transaction, bool notifyDynamicPage) {
    if (notifyDynamicPage) {
      transaction.add("3 notifyBlock()");
      //Что бы не было коллизии setState или marketRebuild во время build
      Util.asyncInvoke((args) {
        try {
          notifyBlock(args);
        } catch (error, stackTrace) {
          Util.log("DataSource.notifyBlockAsync() args: $args; Error: $error", stackTrace: stackTrace, type: "error");
        }
      }, data);
    }
    printTransaction(data, transaction);
  }

  void setDataVirtual(Data data, List<String> transaction, bool notifyDynamicPage) {
    transaction.add("2 is virtual");
    notifyBlockAsync(data, transaction, notifyDynamicPage);
  }

  Future<bool> setDataSocket(Data diffData, List<String> transaction, bool notifyDynamicPage) async {
    bool result = true;
    try {
      // Обновление сокетных данных не должно обновлять локальную БД
      // diffData.uuid - это Primary uuid, если мы в режиме parent надо вытащить локальный uuid
      transaction.add("4 update socket data");
      if (notifyDynamicPage) {
        SocketCache().setDiff(diffData);
      }
      result = await sendDataSocket(diffData, notifyDynamicPage);
      printTransaction(diffData, transaction);
    } catch (error, stackTrace) {
      result = false;
      Util.log("DataSource.setDataSocket() diffData: $diffData; Error: $error", stackTrace: stackTrace, type: "error");
    }
    return result;
  }

  Future<bool> sendDataSocket(Data data, bool notifyDynamicPage) async {
    bool result = true;
    try {
      Map<String, dynamic> postData = {"uuid_data": data.uuid, "data": data.value};
      Response response = await Util.asyncInvokeIsolate((args) {
        return HttpClient.post("${args["host"]}/SocketUpdate", args["body"], args["headers"], debug: args["debug"]);
      }, {
        "headers": HttpClient.upgradeHeadersAuthorization({}),
        "body": postData,
        "host": GlobalSettings().host,
        "debug": GlobalSettings().debugSocketUpdate
      });
      if (response.statusCode != 200) {
        result = false;
        AlertHandler.alertSimple("Данные не зафиксированы на сервере (${response.statusCode})");
        Future.delayed(const Duration(seconds: 1), () {
          SocketCache().renderDBData(data.uuid);
        });
      }
      // Util.p(
      //     "DataSource.sendSocketUpdate() Response Code: ${response.statusCode}; Body: ${response.body}; Headers: ${response.headers}");
    } catch (error, stackTrace) {
      result = false;
      AlertHandler.alertSimple("Данные не зафиксированы на сервере");
      Future.delayed(const Duration(seconds: 1), () {
        SocketCache().renderDBData(data.uuid);
      });
      Util.log("DataSource.sendDataSocket() data: $data; Error: $error", stackTrace: stackTrace, type: "error");
    }
    // тут не будем вызывать синхронизацию данных,
    // так как событие на синхронизацию должно прийти по сокету
    // После http запроса
    return result;
  }

  void updateNullable(Data curData, dynamic dbResult) {
    if (curData.onUpdateOverlayNullField) {
      curData.value ??= dbResult["value_data"];
      curData.parentUuid ??= dbResult["parent_uuid_data"];
      curData.key ??= dbResult["key_data"];
      curData.meta ??= dbResult["meta_data"];
      curData.dateAdd ??= dbResult["date_add_data"];
      curData.dateUpdate ??= dbResult["date_update_data"];
      curData.revision ??= dbResult["revision_data"];
      curData.isRemove ??= dbResult["is_remove_data"];
    }
  }

  void updateOverlayJsonValue(Data curData, dynamic dbResult) {
    if (curData.onUpdateOverlayJsonValue && curData.type.isJson()) {
      Map<String, dynamic> curDataValueMap = {};
      if (curData.value != null) {
        if (curData.value.runtimeType == String) {
          curDataValueMap = json.decode(curData.value);
        } else {
          curDataValueMap = curData.value;
        }
      }
      Map<String, dynamic> dbDataValueMap = {};
      if (dbResult != null &&
          dbResult.containsKey("value_data") &&
          dbResult["value_data"] != null &&
          dbResult["value_data"].runtimeType == String) {
        dbDataValueMap = json.decode(dbResult["value_data"]);
      }
      curData.value = Util.overlay(dbDataValueMap, curDataValueMap);
    }
  }

  Future<bool> updateDataSource(Data curData) async {
    try {
      if (curData.onUpdateResetRevision && curData.type.name.endsWith("RSync")) {
        curData.revision = 0;
      }
      String dataString = curData.value.runtimeType != String ? json.encode(curData.value) : curData.value;
      await db.rawUpdate(
        "UPDATE data SET value_data = ?, type_data = ?, parent_uuid_data = ?, key_data = ?, meta_data = ?, date_add_data = ?, date_update_data = ?, revision_data = ?, is_remove_data = ?, lazy_sync_data = ? WHERE uuid_data = ?",
        [
          dataString,
          curData.type.name,
          curData.parentUuid,
          curData.key,
          curData.meta,
          curData.dateAdd,
          curData.dateUpdate,
          curData.revision,
          curData.isRemove,
          curData.lazySync,
          curData.uuid,
        ],
      );
    } catch (error, stackTrace) {
      Util.log("DataSource.update(); Error: $error", stackTrace: stackTrace, type: "error");
      return false;
    }
    return true;
  }

  Future<bool> insert(Data curData) async {
    try {
      await db.rawInsert(
        'INSERT INTO data (uuid_data, value_data, type_data, parent_uuid_data, key_data, meta_data, date_add_data, date_update_data, revision_data, is_remove_data, lazy_sync_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          curData.uuid,
          curData.value.runtimeType != String ? json.encode(curData.value) : curData.value,
          curData.type.name,
          curData.parentUuid,
          curData.key,
          curData.meta,
          curData.dateAdd ??= Util.getTimestamp(),
          curData.dateUpdate,
          curData.revision ??= 0,
          curData.isRemove ??= 0,
          curData.lazySync
        ],
      );
    } catch (error, stackTrace) {
      Util.log("DataSource.insert(); Error: $error", stackTrace: stackTrace, type: "error");
      return false;
    }
    return true;
  }

  Future<bool> delete(Data curData) async {
    // Будучи в здравии))) Я отдаю отчёт, что удаляя записи из локальной БД может быть фон, что сервер при синхронизации
    // Постоянно будет отдавать их, так как getMaxRevisionByType будет отдавать ревизии меньшии по значению чем удаление
    // А сервер будет говорит, вот смотри тут удаление произошло
    // Так будет продолжаться до тех пор, пока не появится свежая ревизия из этого типа
    // В БД что бы не расходовать место, надо уничтожать данные, но удалять из удалённой БД мы не имеем права
    // Так как если данные были на нескольких устройств, и одно устройство используется реже, то может так получится,
    // Что если на сервере удалить данные, то на второе устройство не дойдёт ревизия удаления и у нас получится рассинхрон
    try {
      await db.rawInsert(
        'DELETE FROM data WHERE uuid_data = ?',
        [curData.uuid],
      );
    } catch (error, stackTrace) {
      Util.log("DataSource.insert(); Error: $error", stackTrace: stackTrace, type: "error");
      return false;
    }
    return true;
  }

  void notifyBlock(Data curData) {
    if (curData.notify) {
      Map<String, dynamic> runtimeData = {};
      if (curData.value.runtimeType == String && curData.type.isJson()) {
        runtimeData = json.decode(curData.value);
      } else if (curData.value.runtimeType != String) {
        if (curData.value.runtimeType.toString().contains("Map<dynamic, dynamic>")) {
          runtimeData = Util.getMutableMap(curData.value);
        } else if (curData.value != null) {
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
  }

  void get(String uuid, Function(String uuid, Map<String, dynamic>? data) handler) {
    if (isInit) {
      db.rawQuery("SELECT * FROM data where uuid_data = ?", [uuid]).then((resultSet) {
        if (resultSet.isNotEmpty && resultSet.first["value_data"] != null) {
          DataType dataTypeResult = Util.dataTypeValueOf(resultSet.first["type_data"] as String?);
          if (dataTypeResult.isJson()) {
            //handler(await Util.asyncInvokeIsolate((arg) => json.decode(arg), resultSet.first["value_data"]));
            handler(resultSet.first["uuid_data"] as String, json.decode(resultSet.first["value_data"] as String));
          } else {
            handler(resultSet.first["uuid_data"] as String, {dataTypeResult.name: resultSet.first["value_data"]});
          }
        } else {
          handler(uuid, null);
        }
      }).onError((error, stackTrace) {
        Util.log("DataSource.get(); Error: $error", stackTrace: stackTrace, type: "error");
      });
    } else {
      list.add(GetterTask(uuid, handler));
    }
  }

  void subscribeUniqueContent(String uuid, Function(String uuid, Map<String, dynamic>? data) callback,
      [bool initGet = true, dynamic lastContent]) {
    subscribe(uuid, (uuid, data) {
      if (lastContent.toString() != data.toString()) {
        lastContent = data;
        callback(uuid, data);
      }
    }, initGet);
  }

  void subscribe(String uuid, Function(String uuid, Map<String, dynamic>? data) callback, [bool initGet = true]) {
    if (initGet) {
      get(uuid, callback);
    }
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
