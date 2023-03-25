import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MD5Handler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    return md5.convert(utf8.encode(args["data"])).toString();
  }
}
