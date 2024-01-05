import '../../db/data_source.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import '../../db/data.dart';
import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import 'abstract_handler.dart';

class DataSourceSetHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["uuid", "value"])) {
      Data data = Data(
        args["uuid"],
        args["value"],
        Util.dataTypeValueOf(args["type"]),
        args["parent"],
      );
      if (args.containsKey("debugTransaction")) {
        data.debugTransaction = args["debugTransaction"];
      }
      if (args.containsKey("beforeSync")) {
        data.beforeSync = args["beforeSync"];
      }
      if (args.containsKey("updateIfExist")) {
        data.updateIfExist = args["updateIfExist"];
      }
      if (args.containsKey("onUpdateOverlayJsonValue")) {
        data.onUpdateOverlayJsonValue = args["onUpdateOverlayJsonValue"];
      }
      if (args.containsKey("key")) {
        data.key = args["key"];
      }
      if (args.containsKey("meta")) {
        data.meta = args["meta"];
      }
      if (args.containsKey("notify")) {
        data.notify = args["notify"];
      }
      if (args["onPersist"] != null) {
        data.onPersist = () {
          AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onPersist");
        };
      }
      DataSource().setData(data);
    } else {
      Util.printCurrentStack("DataSourceSetHandler not contains Keys: [uuid, value] in args: $args");
    }
  }
}

//Это эксперементальная версия, пока есть подозрение, что с внедрением Data.onUpdateOverlayJsonValue
// - функционал не нужен
class DataSourceSetHandler2 extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["uuid", "value"])) {
      if (args.containsKey("createIfNotExist") && args["createIfNotExist"] == true) {
        // Искать по uuid как будто протеворечит созданию, так как uuid сущность уникальная
        // Обычно для новой записи генерируем: var uuid = bridge.call("Util", {"case":"uuid"})["uuid"];
        // Но если очень надо) то используйте дополнительный ключ uuid_find
        // На текущий момент не встречал ещё проблем и потребностей с этим
        List<String> availableDataField = ["uuid_find", "value", "type", "parent_uuid", "key", "revision", "is_remove"];
        String sql = "select * from data where 1 = 1";
        List<dynamic> sqlArgs = [];
        for (String field in availableDataField) {
          if (args.containsKey(field)) {
            sql += " and ${field == "uuid_find" ? "uuid" : field}_data = ?";
            sqlArgs.add(args[field]);
          }
        }
        Util.p("DataSourceSetHandler.handle(createIfNotExist=true) sql: $sql; sqlArgs: $sqlArgs");
        DataSource().db.rawQuery(sql, sqlArgs).then((resultSet) {
          if (resultSet.isEmpty) {
            add(args, dynamicUIBuilderContext);
          }
        }).onError((error, stackTrace) {
          Util.printStackTrace("DataSourceSetHandler.rawQuery() sql: $sql; args: $sqlArgs", error, stackTrace);
        });
      } else {
        add(args, dynamicUIBuilderContext);
      }
    } else {
      Util.printCurrentStack("DataSourceSetHandler not contains Keys: [uuid, value] in args: $args");
    }
  }

  add(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    Data data = Data(
      args["uuid"],
      args["value"],
      Util.dataTypeValueOf(args["type"]),
      args["parent"],
    );
    if (args.containsKey("debugTransaction")) {
      data.debugTransaction = args["debugTransaction"];
    }
    if (args.containsKey("beforeSync")) {
      data.beforeSync = args["beforeSync"];
    }
    if (args.containsKey("updateIfExist")) {
      data.updateIfExist = args["updateIfExist"];
    }
    if (args.containsKey("key")) {
      data.key = args["key"];
    }
    if (args["onPersist"] != null) {
      data.onPersist = () {
        AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onPersist");
      };
    }
    DataSource().setData(data);
  }
}
