import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:rjdu/util.dart';

import '../../controller_wrap.dart';

class StreamWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    StreamCustom stream = getController(parsedJson, "StreamWidget", dynamicUIBuilderContext, () {
      StreamCustom? streamCustom;
      Map<String, dynamic> streamArgs = parsedJson["stream"] ?? {};
      switch (streamArgs["case"] ?? "default") {
        case "Periodic":
          streamCustom = StreamPeriodic(streamArgs["data"], streamArgs["timerMillis"] ?? 1000,
              (Map<String, dynamic> data, Timer timer) {
            if (!data.containsKey("count")) {
              data["count"] = -1;
            }
            data["count"]++;
            if (streamArgs.containsKey("maxCount")) {
              if (data["count"] > streamArgs["maxCount"]) {
                timer.cancel();
              }
            }
          });
          break;
        default:
          streamCustom = StreamData(streamArgs["data"] ?? {});
          break;
      }
      return StreamControllerWrap(streamCustom);
    });

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
  }
}

class StreamControllerWrap extends ControllerWrap<StreamCustom> {
  StreamControllerWrap(super.controller);

  @override
  void dispose() {}

  @override
  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "default") {
      case "default":
        controller.setData(args["data"]);
        break;
    }
  }
}

abstract class StreamCustom {
  Map<String, dynamic> data = {};
  final _controller = StreamController();

  Stream getStream() {
    return _controller.stream;
  }

  Map<String, dynamic> getData() {
    return data;
  }

  setData(Map<String, dynamic> newData) {
    Util.overlay(data, newData);
    _controller.sink.add(data);
  }
}

class StreamPeriodic extends StreamCustom {
  StreamPeriodic(
      Map<String, dynamic> defData, int milliseconds, Function(Map<String, dynamic> data, Timer timer) callback) {
    data = defData;
    Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      callback(data, timer);
      _controller.sink.add(data);
    });
  }
}

class StreamData extends StreamCustom {
  StreamData(Map<String, dynamic> data) {
    this.data = data;
  }
}
