import '../data_type.dart';

class Data {
  String uuid;
  String? parentUuid;
  dynamic value;
  DataType type;
  String? key;
  String? meta;
  int? dateAdd;
  int? dateUpdate;
  int? revision;
  int? isRemove;
  String? lazySync;

  // Если данные по uuid уже есть в БД то при SetDataSource -
  // данные будет обновлены в локальной БД
  bool updateIfExist = true;

  // При SetDataSource нулевые поля заполнятся данными, которые лежат в
  // локальной БД
  bool onUpdateOverlayNullField = true;

  // При установленном флаге будет merge с прекрытием данных из БД, данными, которые прийдут на обновление
  // БД: {"a": "b", "c": "d"} Пришло {"c": "d2", "e": "f"} В результате: {"a": "b", "c": "d2", "e": "f"}
  bool onUpdateOverlayJsonValue = false;

  // При SetDataSource с флагом true будем занулять номер ревизии
  // Это сделано, что бы когда мы в приложении будем обновлять данные - что бы они уходили в синхронизацию с сервером
  // А когда данные прилетают с сервера на синхронизации мы наоборот - Отклчаем занулениии ревизии
  bool onUpdateResetRevision = true;

  // Пока применяется в совокупности с socket данным
  // Если данные до синхронизации (false) - мы будем тут же их отправлять на сервер, то есть вызывать синхронизацию
  // Если данные после синхронизации (true) - мы схлопнем последовательные транзакции и единожны обновим UI через notify
  bool beforeSync = false;

  // Вывод отлаточной информации как прошёл DataSource.setData
  bool debugTransaction = false;

  // Функция выполнится когда данные будут закомичены в локальной БД
  Function? onPersist;

  //Признак, что эти данные относятся к состоянию страницы
  bool isStateData = false;

  //Флаг обновления только ревизии на сервере, к таким данным не будет примеяться notify
  bool notify = true;

  Data(
    this.uuid,
    this.value,
    this.type,
    this.parentUuid,
  );

  @override
  String toString() {
    return 'Data{uuid: $uuid, parentUuid: $parentUuid, value: $value :: ${value.runtimeType}, type: $type, key: $key, meta: $meta, dateAdd: $dateAdd, dateUpdate: $dateUpdate, revision: $revision, isRemove: $isRemove, updateIfExist: $updateIfExist, onUpdateOverlayNullField: $onUpdateOverlayNullField, onUpdateOverlayJsonValue: $onUpdateOverlayJsonValue, onUpdateResetRevision: $onUpdateResetRevision, beforeSync: $beforeSync, debugTransaction: $debugTransaction, onPersist: $onPersist, isStateData: $isStateData; notify: $notify;}';
  }
}
