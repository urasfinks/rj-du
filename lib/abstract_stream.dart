import 'dart:async';

import 'package:rjdu/util.dart';

abstract class AbstractStream {
  Map<String, dynamic> data = {};
  final StreamController _controller = StreamController();
  late final Stream stream;

  AbstractStream() {
    stream = _controller.stream.asBroadcastStream();
  }

  Stream getStream() {
    return stream;
  }

  Map<String, dynamic> getData() {
    return data;
  }

  setData(Map<String, dynamic> newData) {
    Util.overlay(data, newData);
    _controller.add(data);
  }
}
