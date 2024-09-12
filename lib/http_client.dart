import 'dart:convert' show json, utf8, base64;
import 'package:http/http.dart';
import 'package:rjdu/util.dart';
import 'storage.dart';
import 'package:http/http.dart' as http;
import 'global_settings.dart';

class HttpClient {
  static int timeout = 3;
  static String cacheAuthorizationBase64 = "";

  static void init() {
    Util.p("HttpClient.init()");
    Storage().onChange("uuid", "", onUpdateDeviceUuid);
  }

  static Future<Response> get(String url, Map<String, String>? headers, {bool debug = false}) {
    return _configureRequest(
      http.get(Uri.parse(url), headers: headers),
      debug,
      debug ? Util.jsonPretty({"url": url, "headers": headers}) : "",
    );
  }

  static Future<Response> post(String url, Map<String, dynamic> post, Map<String, String>? headers,
      {bool debug = false}) async {
    return _configureRequest(
      http.post(Uri.parse(url), headers: headers, body: json.encode(post)),
      debug,
      debug ? Util.jsonPretty({"url": url, "headers": headers, "post": post}) : "",
    );
  }

  static Future<Response> _configureRequest(Future<Response> obj, bool debug, String requestDataLog) async {
    String uuid = "?";
    if (debug) {
      uuid = Util.uuid();
      Util.log(requestDataLog, type: "request", correlation: uuid);
    }
    return obj.then((value) {
      if (debug) {
        Util.log(
          "StatusCode: ${value.statusCode}; Headers: ${Util.jsonPretty(value.headers)}; Body: ${value.body}",
          type: "response",
          correlation: uuid,
        );
      }
      return value;
    }).timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        if (debug) {
          Util.log(
            "Request timeout",
            correlation: uuid,
            type: "error",
            stack: true,
          );
        }
        return http.Response(
          json.encode({
            "status": false,
            "cause": "Request timeout"
          }),
          408,
        );
      },
    ).onError((error, stackTrace) {
      if (debug) {
        Util.log("$error", type: "error", stackTrace: stackTrace, correlation: uuid);
      }
      return http.Response(
        json.encode({
          "status": false,
          "cause": "Connection failed"
        }),
        417,
      );
    });
  }

  static Map<String, String> upgradeHeadersAuthorization(Map<String, String>? headers) {
    headers ??= {};
    headers["Authorization"] = cacheAuthorizationBase64;
    return headers;
  }

  static void onUpdateDeviceUuid(String value) {
    String decoded = base64.encode(utf8.encode("${GlobalSettings().version}:$value"));
    cacheAuthorizationBase64 = "Basic $decoded";
  }
}
