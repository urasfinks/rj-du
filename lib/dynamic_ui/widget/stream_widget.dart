import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:rjdu/util.dart';

class StreamWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    CustomStream? stream;
    if (parsedJson.containsKey("stream")) {
      Map<String, dynamic> argStream = parsedJson["stream"];
      switch (argStream["name"]) {
        case "Periodic":
          stream = PeriodicStream(argStream["data"], argStream["timerMillis"] ?? 1000,
              (Map<String, dynamic> data, Timer timer) {
            if (!data.containsKey("count")) {
              data["count"] = -1;
            }
            data["count"]++;
            if (argStream.containsKey("maxCount")) {
              if (data["count"] > argStream["maxCount"]) {
                timer.cancel();
              }
            }
          });
          break;
      }
    }
    if (stream != null) {
      return StreamBuilder(
        key: Util.getKey(),
        stream: stream.getStream(),
        builder: (BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
          DynamicUIBuilderContext newDynamicUIBuilderContext = dynamicUIBuilderContext.cloneWithNewData(
            Util.convertMap(asyncSnapshot.data ?? {}),
            parsedJson["key"] ?? "StreamWidget",
          );
          return render(parsedJson, "child", const SizedBox(), newDynamicUIBuilderContext);
        },
        initialData: stream.getData(),
      );
    } else {
      return Text("StreamWidget() stream for $parsedJson is null");
    }
  }
}

abstract class CustomStream {
  Map<String, dynamic> data = {};
  final _controller = StreamController();

  Stream getStream() {
    return _controller.stream;
  }

  Map<String, dynamic> getData() {
    return data;
  }
}

class PeriodicStream extends CustomStream {
  PeriodicStream(
      Map<String, dynamic> data, int milliseconds, Function(Map<String, dynamic> data, Timer timer) callback) {
    this.data = data;
    Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      callback(data, timer);
      _controller.sink.add(data);
    });
  }
}

class AudioStream extends CustomStream {
  AudioStream(Map<String, dynamic> data) {
    this.data = data;
  }

  void notify() {
    _controller.sink.add(data);
  }
}
