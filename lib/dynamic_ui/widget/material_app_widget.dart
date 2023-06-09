import 'package:flutter/material.dart';
import '../../global_settings.dart';
import '../../system_notify.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import '../../bottom_tab.dart';
import '../../theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MaterialAppWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return OrientationBuilder(
      builder: (context, orientation) {
        SystemNotify().emit(SystemNotifyEnum.changeOrientation, orientation.name);
        return MaterialApp(
          debugShowCheckedModeBanner: GlobalSettings().debug,
          theme: ThemeProvider.lightThemeData(),
          darkTheme: ThemeProvider.darkThemeData(),
          themeMode: ThemeMode.system,
          home: BottomTab(dynamicUIBuilderContext),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ru'), // Spanish
          ],
        );
      },
    );
  }
}
