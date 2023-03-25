
import 'data_source.dart';

class DataGetter {
  static Future<Map<String, int>> getMaxRevisionByType() async {
    Map<String, int> result = {};
    var resultSet =
        await DataSource().db.rawQuery('SELECT type_data, max(revision_data) as max FROM data GROUP BY type_data', []);
    for (Map<String, dynamic> item in resultSet) {
      result[item['type_data']] = item['max'];
    }
    return result;
  }
}
