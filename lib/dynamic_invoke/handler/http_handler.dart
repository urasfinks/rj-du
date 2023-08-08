import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:rjdu/dynamic_invoke/handler/abstract_handler.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/util.dart';

import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../http_client.dart';
import '../../global_settings.dart';

class HttpHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    args = Util.getMutableMap(args);

    args["headers"] = HttpClient.upgradeHeadersAuthorization(args["headers"]);
    if (!args.containsKey("host")) {
      args["host"] = GlobalSettings().host;
    }
    if (!args.containsKey("method")) {
      args["method"] = "POST";
    }

    Future<Response> response;
    if (args["method"] == "POST") {
      response = HttpClient.post("${args["host"]}${args["uri"]}", args["body"], args["headers"]);
    } else {
      response = HttpClient.get("${args["host"]}${args["uri"]}", args["headers"]);
    }
    response.then((value) {
      if (args.containsKey("onResponse")) {
        Map<String, Object> httpResponseObject = {};
        httpResponseObject["status"] = value.statusCode == 200;
        httpResponseObject["headers"] = value.headers;
        httpResponseObject["statusCode"] = value.statusCode;
        httpResponseObject["rawBody"] = value.body;

        print(httpResponseObject);

        if (httpResponseObject["status"] != true) {
          httpResponseObject["error"] = "Сервер вернул ошибку ${value.statusCode}";
        }

        try {
          Map<String, dynamic> data = json.decode(value.body);
          httpResponseObject["data"] = data;
          if (data.containsKey("status") && data["status"] == false) {
            httpResponseObject["status"] = false;
            if (data.containsKey("description")) {
              httpResponseObject["error"] = data["description"];
            } else if (data.containsKey("exception")) {
              String ex = data["exception"][0] as String;
              httpResponseObject["error"] = ex.length > 100 ? ex.substring(0, 100) : ex;
              if (kDebugMode) {
                print(data["exception"]);
              }
            }
          }
        } catch (e) {
          httpResponseObject["status"] = false;
          httpResponseObject["error"] = e.toString();
        }

        args["onResponse"]["args"]["httpResponse"] = httpResponseObject;
        AbstractWidget.clickStatic(args, dynamicUIBuilderContext, "onResponse");
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
    });
  }
}
