import 'package:carousel_slider/carousel_slider.dart';
import 'package:rjdu/controller_wrap.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/abstract_widget.dart';
import 'package:flutter/material.dart';

import '../../dynamic_invoke/handler/alert_handler.dart';
import '../../util.dart';
import '../type_parser.dart';

class CarouselSliderWidget extends AbstractWidget {
  @override
  get(Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    parsedJson["state"] ??= "Key";
    Map<String, dynamic> stateControl = AbstractWidget.getStateControl(
      parsedJson["state"],
      dynamicUIBuilderContext,
      {
        "index": 0,
        "index1": 1,
        "prc": 0,
        "prc1": 0,
        "scroll": 0,
      },
    );
    if (parsedJson.containsKey("finish") && stateControl.containsKey("finish") && stateControl["finish"]) {
      return render(parsedJson["finish"], null, const SizedBox(), dynamicUIBuilderContext);
    }
    CarouselController carouselController = getController(parsedJson, "CarouselSlider", dynamicUIBuilderContext, () {
      return CarouselControllerWrap(CarouselController());
    });

    List children = [];
    if (parsedJson.containsKey("children")) {
      children = updateList(parsedJson["children"] as List, dynamicUIBuilderContext);
    }

    CenterPageEnlargeStrategy defStrategy = CenterPageEnlargeStrategy.scale;
    switch (parsedJson["enlargeStrategy"] ?? "") {
      case "scale":
        defStrategy = CenterPageEnlargeStrategy.scale;
        break;
      case "height":
        defStrategy = CenterPageEnlargeStrategy.height;
        break;
      case "zoom":
        defStrategy = CenterPageEnlargeStrategy.zoom;
        break;
    }

    return CarouselSlider(
      key: Util.getKey(),
      carouselController: carouselController,
      options: CarouselOptions(
        height: TypeParser.parseDouble(
          getValue(parsedJson, "height", null, dynamicUIBuilderContext),
        ),
        aspectRatio: TypeParser.parseDouble(
          getValue(parsedJson, "aspectRatio", 16 / 9, dynamicUIBuilderContext),
        )!,
        viewportFraction: TypeParser.parseDouble(
          getValue(parsedJson, "viewportFraction", 1.0, dynamicUIBuilderContext),
        )!,
        initialPage: TypeParser.parseInt(
          getValue(parsedJson, "initialPage", 0, dynamicUIBuilderContext),
        )!,
        enableInfiniteScroll: TypeParser.parseBool(
          getValue(parsedJson, "enableInfiniteScroll", true, dynamicUIBuilderContext),
        )!,
        animateToClosest: TypeParser.parseBool(
          getValue(parsedJson, "animateToClosest", true, dynamicUIBuilderContext),
        )!,
        reverse: TypeParser.parseBool(
          getValue(parsedJson, "reverse", false, dynamicUIBuilderContext),
        )!,
        autoPlay: TypeParser.parseBool(
          getValue(parsedJson, "autoPlay", false, dynamicUIBuilderContext),
        )!,
        autoPlayInterval: Duration(
            seconds: TypeParser.parseInt(
          getValue(parsedJson, "autoPlayInterval", 4, dynamicUIBuilderContext),
        )!),
        autoPlayAnimationDuration: Duration(
            seconds: TypeParser.parseInt(
          getValue(parsedJson, "autoPlayAnimationDuration", 800, dynamicUIBuilderContext),
        )!),
        autoPlayCurve: TypeParser.parseCurve(
          getValue(parsedJson, "autoPlayCurve", "fastOutSlowIn", dynamicUIBuilderContext),
        )!,
        enlargeCenterPage: TypeParser.parseBool(
          getValue(parsedJson, "enlargeCenterPage", true, dynamicUIBuilderContext),
        ),
        onPageChanged: (index, reason) {
          if (children.isNotEmpty) {
            stateControl["index"] = index;
            stateControl["index1"] = index + 1;
            stateControl["prc"] = (index * 100 / children.length).ceil();
            stateControl["prc1"] = index * 1 / children.length;
            AbstractWidget.clickStatic(parsedJson, dynamicUIBuilderContext, "onPageChanged");
            if (parsedJson["setState"] ?? parsedJson["setStateOnPageChanged"] ?? false == true) {
              dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
            }
          }
        },
        onScrolled: (scroll) {
          stateControl["scroll"] = scroll;
          AbstractWidget.clickStatic(parsedJson, dynamicUIBuilderContext, "onScrolled");
          if (parsedJson["setState"] ?? parsedJson["setStateOnScrolled"] ?? false == true) {
            dynamicUIBuilderContext.dynamicPage.stateData.setMap(parsedJson["state"], stateControl);
          }
        },
        scrollPhysics: Util.getPhysics(),
        pageSnapping: TypeParser.parseBool(
          getValue(parsedJson, "pageSnapping", true, dynamicUIBuilderContext),
        )!,
        scrollDirection: TypeParser.parseAxis(
          getValue(parsedJson, "scrollDirection", "horizontal", dynamicUIBuilderContext),
        )!,
        pauseAutoPlayOnTouch: TypeParser.parseBool(
          getValue(parsedJson, "pauseAutoPlayOnTouch", true, dynamicUIBuilderContext),
        )!,
        pauseAutoPlayOnManualNavigate: TypeParser.parseBool(
          getValue(parsedJson, "pauseAutoPlayOnManualNavigate", true, dynamicUIBuilderContext),
        )!,
        pauseAutoPlayInFiniteScroll: TypeParser.parseBool(
          getValue(parsedJson, "pauseAutoPlayInFiniteScroll", false, dynamicUIBuilderContext),
        )!,
        enlargeStrategy: defStrategy,
        enlargeFactor: TypeParser.parseDouble(
          getValue(parsedJson, "enlargeFactor", 0.3, dynamicUIBuilderContext),
        )!,
        disableCenter: TypeParser.parseBool(
          getValue(parsedJson, "disableCenter", false, dynamicUIBuilderContext),
        )!,
        padEnds: TypeParser.parseBool(
          getValue(parsedJson, "padEnds", true, dynamicUIBuilderContext),
        )!,
        clipBehavior: TypeParser.parseClip(
          getValue(parsedJson, "clipBehavior", "hardEdge", dynamicUIBuilderContext),
        )!,
      ),
      items: renderList(parsedJson, "children", dynamicUIBuilderContext),
    );
  }
}

class CarouselControllerWrap extends ControllerWrap<CarouselController> {
  CarouselControllerWrap(super.controller);

  @override
  void invoke(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    switch (args["case"] ?? "default") {
      case "startAutoPlay":
        controller.startAutoPlay();
        break;
      case "stopAutoPlay":
        controller.stopAutoPlay();
        break;
      case "jumpToPage":
        controller.jumpToPage(args["page"]);
        break;
      case "animateToPage":
        controller.animateToPage(args["page"]);
        break;
      case "nextPage":
        controller.nextPage();
        break;
      case "previousPage":
        controller.previousPage();
        break;
      default:
        AlertHandler.alertSimple("CarouselControllerWrap.invoke() args: $args");
        break;
    }
  }

  @override
  void dispose() {}
}
