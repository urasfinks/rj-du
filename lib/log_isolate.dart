import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:rjdu/util.dart';

import 'global_settings.dart';

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
    if (kDebugMode && GlobalSettings().debug) {
      ReceivePort port = ReceivePort();
      port.listen((message) {
        LogIsolate().log(message);
      });
      LogIsolate().sendPort = port.sendPort;
    }
  }

  void iamIsolate(SendPort? sp) {
    isolate = true;
    sendPort = sp;
  }

  // Множественное распостранение порта от изолята к изоляту
  SendPort? getSendPort() {
    return sendPort;
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
      if (removeFirst.length > 1000) {
        Util.asyncInvokeIsolate((str) {
          _splitWrite(str);
        }, removeFirst)
            .then((value) {
          next();
        });
      } else {
        print(removeFirst);
        // Flutter 3.27.0 deprecated stdout.write
        //stdout.write(removeFirst);
        //stdout.writeln();
        //stdout.flush();
        next();
      }
    } else {
      oldOpComplete = true;
    }
  }

  void _splitWrite(str) {
    int spLen = 1000;
    int max = 10;
    while (str.length > spLen) {
      if (max <= 0) {
        break;
      }
      stdout.write(str.substring(0, spLen));
      str = str.substring(spLen);
      max--;
    }
    if (max <= 0) {
      stdout.writeln("... more ${spLen * max}");
    } else {
      stdout.write(str);
    }
    stdout.writeln();
  }
}
