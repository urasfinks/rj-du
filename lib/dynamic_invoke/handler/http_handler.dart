import 'dart:convert';

import 'package:http/http.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';

import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../http_client.dart';
import '../../global_settings.dart';

class HttpHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args,
      DynamicUIBuilderContext dynamicUIBuilderContext) {
    args["headers"] = HttpClient.upgradeHeadersAuthorization(args["headers"]);
    if (!args.containsKey("host")) {
      args["host"] = GlobalSettings().host;
    }
    if (!args.containsKey("method")) {
      args["method"] = "POST";
    }

    Future<Response> response;
    if (args["method"] == "POST") {
      response = HttpClient.post(
          "${args["host"]}${args["uri"]}", args["body"], args["headers"]);
    } else {
      response =
          HttpClient.get("${args["host"]}${args["uri"]}", args["headers"]);
    }
    response.then((value) {
      if (args.containsKey("onResponse")) {
        try {
          args["onResponse"]["args"]["body"] = json.decode(value.body);
        } catch (e) {
          args["onResponse"]["args"]["body"] = {
            'status': false,
            'exception': [e.toString()]
          };
        }
        args["onResponse"]["args"]["headers"] = value.headers;
        args["onResponse"]["args"]["statusCode"] = value.statusCode;
        AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onResponse");
      }
    });
  }
}
