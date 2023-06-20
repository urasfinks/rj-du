import 'dart:convert';
import 'dart:ui';

import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/system_notify.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'dynamic_page.dart';
import 'storage.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _singleton = WebSocketService._internal();
  Cron? cron;

  factory WebSocketService() {
    return _singleton;
  }

  void init() {
    cron = Cron();
    cron!.schedule(Schedule.parse("*/5 * * * * *"), check);
    SystemNotify().listen(SystemNotifyEnum.appLifecycleState, (state) {
      var isActive = state == AppLifecycleState.resumed.name;
      if (isActive) {
        check();
      } else {
        _disconnect();
      }
      if (kDebugMode) {
        print(
            "WebSocketService:init:SystemNotify.emit(AppLifecycleState) => $state; isActive: $isActive");
      }
    });
  }

  List<DynamicPage> list = [];

  WebSocketService._internal();

  WebSocketChannel? _channel;

  void _connect() {
    if (_channel == null) {
      try {
        if (kDebugMode) {
          print('WebSocketService._connect() start connect');
        }
        WebSocket.connect(
                "${GlobalSettings().host}/${Storage().get('uuid', 'undefined')}")
            .timeout(const Duration(seconds: 4))
            .then((ws) {
          try {
            _disconnect(); //Если кто-то уже создал коннект
            _channel = IOWebSocketChannel(ws);
            if (kDebugMode) {
              print('WebSocketService._connect() connect chanel');
            }
            if (_channel != null) {
              _listen(_channel!);
              if (kDebugMode) {
                print('WebSocketService._connect() channel.stream.listen');
              }
            }
          } catch (e, stacktrace) {
            _log(e, stacktrace);
            _disconnect();
          }
        });
      } catch (e, stacktrace) {
        _log(e, stacktrace);
        _disconnect();
      }
    }
  }

  void _listen(WebSocketChannel channel) {
    channel.stream.listen(
      (message) {
        if (kDebugMode) {
          print("WebSocketService._listen()::onRead($message)");
        }
        Map<String, dynamic> jsonDecoded = json.decode(message);
      },
      onDone: () {
        _disconnect();
      },
      onError: (e, stacktrace) {
        _log(e, stacktrace);
        _disconnect();
      },
    );
  }

  void _log(e, stacktrace) {
    if (kDebugMode) {
      print(e);
      print(stacktrace);
    }
  }

  void _disconnect() {
    if (_channel != null) {
      try {
        if (kDebugMode) {
          print("WebSocketService._disconnect() start disconnect");
        }
        _channel!.sink.close(status.goingAway);
        if (kDebugMode) {
          print("WebSocketService._disconnect() _channel.close()");
        }
      } catch (e, stacktrace) {
        _log(e, stacktrace);
      }
    }
    _channel = null;
  }

  void check() {
    if (list.isNotEmpty) {
      _connect();
    } else {
      _disconnect();
    }
  }

  void addPage(DynamicPage dynamicPage) {
    if (!list.contains(dynamicPage)) {
      list.add(dynamicPage);
    }
    check();
  }

  void removePage(DynamicPage dynamicPage) {
    if (list.contains(dynamicPage)) {
      list.remove(dynamicPage);
    }
    check();
  }
}
