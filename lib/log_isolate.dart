import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:rjdu/util.dart';

// Транс поточное логироние с соблюдением последовательности вывода
class LogIsolate {
  static final LogIsolate _singleton = LogIsolate._internal();

  bool isolate = false;

  SendPort? sendPort;

  Queue<String> queue = Queue();

  bool oldOpComplete = true;

  LogIsolate._internal();

  factory LogIsolate() {
    return _singleton;
  }

  void init() {
    ReceivePort port = ReceivePort();
    port.listen((message) {
      if (kDebugMode) {
        LogIsolate().log(message);
      }
    });
    LogIsolate().sendPort = port.sendPort;
  }

  void iamIsolate(SendPort sp) {
    isolate = true;
    sendPort = sp;
  }

  // Множественное распостранение порта от изолята к изоляту
  SendPort getSendPort() {
    return sendPort!;
  }

  void log(String msg) {
    if (isolate) {
      sendPort!.send(msg);
    } else {
      queue.add(msg);
      // Если прошлое обещание закончено, запускаем новое
      // А если нет, оно само подхватит новые записи из очереди
      if (oldOpComplete) {
        oldOpComplete = false;
        next();
      }
    }
  }

  void next() {
    if (queue.isNotEmpty) {
      String removeFirst = queue.removeFirst();
      Util.asyncInvokeIsolate((str) {
        int spLen = 1000;
        while (str.length > spLen) {
          stdout.write(str.substring(0, spLen));
          str = str.substring(spLen);
        }
        stdout.write(str);
        stdout.writeln();
      }, removeFirst)
          .then((value) {
        next();
      });
    } else {
      oldOpComplete = true;
    }
  }
}
