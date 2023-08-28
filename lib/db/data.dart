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

  // Данные залетают после синхронизации
  bool beforeSync = false;

  // Вывод отлаточной информации как прошёл DataSource.setData
  bool debugTransaction = false;

  // Функция выполнится когда данные будут закомичены в локальной БД
  Function? onPersist;

  //Признак, что эти данные относятся к состоянию страницы
  bool isStateData = false;

  Data(
    this.uuid,
    this.value,
    this.type,
    this.parentUuid,
  );

  @override
  String toString() {
    return 'Data{uuid: $uuid, parentUuid: $parentUuid, value: $value :: ${value.runtimeType}, type: $type, key: $key, dateAdd: $dateAdd, dateUpdate: $dateUpdate, revision: $revision, isRemove: $isRemove, updateIfExist: $updateIfExist, onUpdateOverlayNullField: $onUpdateOverlayNullField, onUpdateResetRevision: $onUpdateResetRevision, beforeSync: $beforeSync, onPersist: $onPersist}';
  }
}
