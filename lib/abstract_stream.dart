import 'dart:async';

import 'package:rjdu/util.dart';

abstract class AbstractStream {
  Map<String, dynamic> data = {};
  StreamController controller = StreamController();

  Stream getStream() {
    controller = StreamController();
    return controller.stream;
  }

  Map<String, dynamic> getData() {
    return data;
  }

  setData(Map<String, dynamic> newData) {
    Util.overlay(data, newData);
    controller.sink.add(data);
  }
}