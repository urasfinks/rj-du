import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:rjdu/util.dart';

import '../../abstract_controller_wrap.dart';
import '../../abstract_stream.dart';

class StreamWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    AbstractStream stream = getController(parsedJson, "StreamWidget", dynamicUIBuilderContext, () {
      AbstractStream? abstractStream;
      Map<String, dynamic> streamArgs = parsedJson["stream"] ?? {};
      switch (streamArgs["case"] ?? "default") {
        case "Periodic":
          abstractStream = StreamPeriodic(streamArgs["data"], streamArgs["timerMillis"] ?? 1000,
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
          abstractStream = StreamData(streamArgs["data"] ?? {});
          break;
      }
      return StreamControllerWrap(abstractStream);
    });

    return getWidget(stream, (data) {
      DynamicUIBuilderContext newDynamicUIBuilderContext = dynamicUIBuilderContext.cloneWithNewData(
        Util.convertMap(data),
        parsedJson["key"] ?? "StreamWidget",
      );
      return render(parsedJson, "child", const SizedBox(), newDynamicUIBuilderContext);
    });
  }

  static Widget getWidget(AbstractStream stream, dynamic Function(Map<String, dynamic> data) builder) {
    return StreamBuilder(
      key: Util.getKey(),
      stream: stream.getStream(),
      builder: (BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
        Map<String, dynamic> snapshot = asyncSnapshot.data ?? {};
        return builder(snapshot);
      },
      initialData: stream.getData(),
    );
  }
}

class StreamControllerWrap extends AbstractControllerWrap<AbstractStream> {
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

class StreamPeriodic extends AbstractStream {
  StreamPeriodic(
      Map<String, dynamic> defData, int milliseconds, Function(Map<String, dynamic> data, Timer timer) callback) {
    data = defData;
    Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      callback(data, timer);
      controller.sink.add(data);
    });
  }
}

class StreamData extends AbstractStream {
  StreamData(Map<String, dynamic> data) {
    this.data = data;
  }
}
