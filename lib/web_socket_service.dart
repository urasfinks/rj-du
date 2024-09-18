import 'dart:ui';

import 'package:cron/cron.dart';
import 'package:rjdu/data_sync.dart';
import 'package:rjdu/global_settings.dart';
import 'package:rjdu/multi_invoke.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/util.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'dynamic_invoke/handler/alert_handler.dart';
import 'dynamic_page.dart';
import 'storage.dart';
import 'package:web_socket_channel/status.dart' as status;

// Как всегда всё очень просто, если DynamicPage хочет слушать сокет и сокет реально ещё не поднят - cокет открывается
// Нет никаких подписок на прослушку каких-либо данных + мы ничего никогда не передаём в сокет - только слушаем
// Если сервер решит нашему uuid устройству чтолибо отдать, сервер пришлёт уведомление по сокету
// Уведомление будет содержать только лишь информацию, что надо синхронизировать данные с сервером
// Дальше всё по стандарнтной траектории - страницы подписываются на какие-то локальные данные в локальной БД
// И когда данные обновляются - происходит перерисовка страницы

class WebSocketService {
  static final WebSocketService _singleton = WebSocketService._internal();
  Cron? _cron;
  bool appIsActive = true;

  factory WebSocketService() {
    return _singleton;
  }

  void init() {
    _cron = Cron();
    _cron!.schedule(Schedule.parse("*/5 * * * * *"), check);
    SystemNotify().subscribe(SystemNotifyEnum.appLifecycleState, (state) {
      appIsActive = state == AppLifecycleState.resumed.name;
      if (appIsActive) {
        check();
      } else {
        _disconnect();
      }
      Util.p("WebSocketService:init:SystemNotify.emit(AppLifecycleState) => $state; isActive: $appIsActive");
    });
  }

  final List<DynamicPage> _list = [];

  WebSocketService._internal();

  WebSocketChannel? _channel;

  MultiInvoke controlTimeout = MultiInvoke(4100);

  void _connect() {
    if (_channel == null) {
      try {
        Util.p("WebSocketService._connect() start connect");
        int timeoutMillis = 4000;
        controlTimeout.delayMillis = timeoutMillis + 100;
        controlTimeout.invoke(() {
          if (_channel == null) {
            Util.p("${GlobalSettings().ws}/socket/${Storage().get("uuid", "undefined")} timeout");
            AlertHandler.alertSimple("Связь с сервером не установлена");
          }
        });
        WebSocket.connect("${GlobalSettings().ws}/socket/${Storage().get("uuid", "undefined")}")
            .timeout(Duration(milliseconds: timeoutMillis))
            .then((ws) {
          try {
            _disconnect(); //Если кто-то уже создал коннект
            _channel = IOWebSocketChannel(ws);
            Util.p("WebSocketService._connect() connect chanel");
            if (_channel != null) {
              _listen(_channel!);
              Util.p("WebSocketService._connect() channel.stream.listen");
              controlTimeout.stop();
            }
          } catch (e, stacktrace) {
            _log(e, stacktrace, "_disconnect()");
            _disconnect();
          }
        }).onError((error, stackTrace) {
          Util.log("WebSocketService._connect(); Error: $error", stackTrace: stackTrace, type: "error");
        });
      } catch (e, stacktrace) {
        _log(e, stacktrace, "_connect()");
        _disconnect();
      }
    }
  }

  void _listen(WebSocketChannel channel) {
    channel.stream.listen(
      (message) {
        Util.p("WebSocketService._listen()::onRead($message)");
        // TODO: доработать парсинг сообщения,
        // Map<String, dynamic> jsonDecoded = json.decode(message);
        // но пока обработчик будет только запуск синхронизации
        DataSync().sync();
      },
      onDone: () {
        _disconnect();
      },
      onError: (e, stacktrace) {
        _log(e, stacktrace, "_listen()");
        _disconnect();
      },
    );
  }

  void _log(error, stackTrace, String extra) {
    Util.log("WebSocketService._log() $extra; Error: $error", stackTrace: stackTrace, type: "error");
  }

  void _disconnect() {
    if (_channel != null) {
      try {
        Util.p("WebSocketService._disconnect() start disconnect");
        _channel!.sink.close(status.goingAway);
        Util.p("WebSocketService._disconnect() _channel.close()");
      } catch (e, stacktrace) {
        _log(e, stacktrace, "_disconnect");
      }
    }
    _channel = null;
  }

  void check() {
    if (appIsActive) {
      if (_list.isNotEmpty) {
        _connect();
      } else {
        _disconnect();
      }
    }
  }

  void addListener(DynamicPage dynamicPage) {
    if (!_list.contains(dynamicPage)) {
      _list.add(dynamicPage);
    }
    check();
  }

  void removeListener(DynamicPage dynamicPage) {
    if (_list.contains(dynamicPage)) {
      _list.remove(dynamicPage);
    }
    check();
  }
}
