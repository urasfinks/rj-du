import 'dart:convert' show json, utf8, base64;
import 'package:http/http.dart';
import 'package:rjdu/util.dart';
import 'storage.dart';
import 'package:http/http.dart' as http;
import 'global_settings.dart';

class HttpClient {
  static int timeout = 3;
  static String? cacheAuthorizationBase64;

  static void init() {
    Util.p("HttpClient.init()");
    Storage().onChange("uuid", "", onUpdateDeviceUuid);
  }

  static Future<Response> get(String url, Map<String, String>? headers) {
    return _configureRequest(
      http.get(Uri.parse(url), headers: headers),
      "$url, $headers",
    );
  }

  static Future<Response> post(String url, Map<String, dynamic> post, Map<String, String>? headers) async {
    return _configureRequest(
      http.post(Uri.parse(url), headers: headers, body: json.encode(post)),
      "$url, $post, $headers",
    );
  }

  static Future<Response> _configureRequest(Future<Response> obj, String logArgs) async {
    return obj.timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        return http.Response(
            json.encode({
              "status": false,
              "exception": ["Request timeout"]
            }),
            408);
      },
    );
  }

  static Map<String, String> upgradeHeadersAuthorization(Map<String, String>? headers) {
    headers ??= {};
    headers["Authorization"] = cacheAuthorizationBase64!;
    return headers;
  }

  static void onUpdateDeviceUuid(String value) {
    String decoded = base64.encode(utf8.encode("${GlobalSettings().version}:$value"));
    cacheAuthorizationBase64 = "Basic $decoded";
  }
}
