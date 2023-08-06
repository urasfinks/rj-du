import 'package:flutter/material.dart';
import 'package:rjdu/navigator_app.dart';
import '../../dynamic_invoke/dynamic_invoke.dart';
import '../../dynamic_invoke/handler/navigator_pop_handler.dart';
import '../../global_settings.dart';
import '../../system_notify.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import '../../bottom_tab.dart';
import '../../theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MaterialAppWidget extends AbstractWidget {
  String lastOrientation = "";

  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (lastOrientation != orientation.name) {
          lastOrientation = orientation.name;
          SystemNotify().emit(SystemNotifyEnum.changeOrientation, orientation.name);
        }
        return MaterialApp(
          debugShowCheckedModeBanner: GlobalSettings().debug,
          theme: ThemeProvider.lightThemeData(),
          darkTheme: ThemeProvider.darkThemeData(),
          themeMode: ThemeMode.system,
          home: WillPopScope(
            onWillPop: () async {
              bool result = NavigatorApp.isLast();
              DynamicInvoke().sysInvokeType(
                NavigatorPopHandler,
                {},
                NavigatorApp.getLast()!.dynamicUIBuilderContext,
              );
              return result;
            },
            child: BottomTab(dynamicUIBuilderContext),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale("en"), // English
            Locale("ru"), // Spanish
          ],
        );
      },
    );
  }
}
