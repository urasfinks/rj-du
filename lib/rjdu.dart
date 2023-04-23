library rjdu;

import 'package:flutter/cupertino.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/translate.dart';
import 'package:uuid/uuid.dart';
import 'data_sync.dart';
import 'db/data_source.dart';
import 'dynamic_invoke/dynamic_invoke.dart';
import 'navigator_app.dart';
import 'storage.dart';
import 'http_client.dart';

class RjDu {
  static void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Storage().init();
    GlobalSettings().init();

    Storage().set('uuid', const Uuid().v4(), false);
    Storage().set('version', GlobalSettings().version, false);
    Storage().set('isAuth', "false", false);

    DataSource().init();
    DynamicInvoke().init();
    HttpClient.init();
    Translate().init();
    DataSync().init();

    SystemNotify().listen(SystemNotifyEnum.changeTabOrHistoryPop, (state) {
      //print("onRenderOtherPage: $state;");
      NavigatorApp.getLast()?.renderFloatingActionButton();
    });
  }
}
