import '../data_type.dart';

class Data {
  String uuid;
  String? parentUuid;
  dynamic value;
  DataType type;
  String? key;
  int? dateAdd;
  int? dateUpdate;
  int? revision;
  int? isRemove;

  // Если данные по uuid уже есть в БД то при SetDataSource -
  // данные будет обновлены в локальной БД
  bool updateIfExist = true;

  // При SetDataSource нулевые поля заполнятся данными, которые лежат в
  // локальной БД
  bool onUpdateOverlayNullField = true;

  // При SetDataSource с флагом true будем занулять номер ревизии
  // Это сделано, что бы когда мы в приложении будем обновлять данные они
  // уходили в синхронизацию с сервером
  // А когда данные прилетают с сервера на синхронизации мы наоборот
  // Отклчаем занулениии ревизии
  bool onUpdateResetRevision = true;

  // Если данные попадут в SetDataSource и флаг будет false они не обновятся
  // в локальной БД
  bool saveToDb = true;

  // Функция выполнится когда данные будут закомичены в локальной БД
  Function? onPersist;

  Data(
    this.uuid,
    this.value,
    this.type,
    this.parentUuid,
  );

  @override
  String toString() {
    return 'Data{uuid: $uuid, parentUuid: $parentUuid, value: $value, type: $type, key: $key, dateAdd: $dateAdd, dateUpdate: $dateUpdate, revision: $revision, isRemove: $isRemove, updateIfExist: $updateIfExist, cloneFieldIfNull: $onUpdateOverlayNullField, onUpdateResetRevision: $onUpdateResetRevision, saveToDb: $saveToDb, onPersist: $onPersist}';
  }
}
