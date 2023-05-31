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

  bool updateIfExist = true;
  bool cloneFieldIfNull = true;
  bool onUpdateResetRevision = true;
  bool saveToDb = true;
  Function? onPersist;

  Data(
    this.uuid,
    this.value,
    this.type,
    this.parentUuid,
  );

  @override
  String toString() {
    return 'Data{uuid: $uuid, parentUuid: $parentUuid, value: $value, type: $type, key: $key, dateAdd: $dateAdd, dateUpdate: $dateUpdate, revision: $revision, updateIfExist: $updateIfExist, cloneFieldIfNull: $cloneFieldIfNull}';
  }
}
