import '../data_type.dart';
import 'data_source.dart';

class DataGetter {
  static Future<List<Map<String, dynamic>>> getUpdatedUserData() async {
    return await DataSource().db.rawQuery(
        'SELECT * FROM data WHERE type_data = ? AND revision_data = 0',
        [DataType.userDataRSync.name]);
  }

  static Future<List<Map<String, dynamic>>> getAddSocketData() async {
    return await DataSource().db.rawQuery(
        'SELECT * FROM data WHERE type_data = ? AND revision_data = 0',
        [DataType.socket.name]);
  }

  static Future<List<Map<String, dynamic>>> resetRevision(DataType dataType, int fromRevision, int toRevision) async {
    return await DataSource().db.rawQuery(
        'UPDATE data SET revision_data = 0 WHERE type_data = ? AND revision_data >= ? AND revision_data <= ?',
        [dataType.name, fromRevision, toRevision]);
  }

  static Future<Map<String, int>> getMaxRevisionByType() async {
    Map<String, int> result = {};
    var resultSet = await DataSource().db.rawQuery(
        'SELECT type_data, max(revision_data) as max FROM data GROUP BY type_data',
        []);
    for (Map<String, dynamic> item in resultSet) {
      result[item['type_data']] = item['max'];
    }
    for (DataType dataType in DataType.values) {
      //Добиваем нулями несуществующие типы из БД
      if (!result.containsKey(dataType.name)) {
        if (dataType != DataType.virtual) {
          result[dataType.name] = 0;
        }
      }
    }
    return result;
  }
}
