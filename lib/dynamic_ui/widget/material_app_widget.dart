import 'package:flutter/material.dart';
import '../../global_settings.dart';
import '../dynamic_ui_builder_context.dart';
import '../widget/abstract_widget.dart';
import '../../bottom_tab.dart';
import '../../theme_provider.dart';

class MaterialAppWidget extends AbstractWidget {
  @override
  Widget get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return MaterialApp(
      debugShowCheckedModeBanner: GlobalSettings.debug,
      theme: ThemeProvider.lightThemeData(),
      darkTheme: ThemeProvider.darkThemeData(),
      themeMode: ThemeMode.system,
      home: BottomTab(dynamicUIBuilderContext),
    );
  }
}
