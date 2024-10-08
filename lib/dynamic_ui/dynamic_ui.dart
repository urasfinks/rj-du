import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/align_widget.dart';
import 'package:rjdu/dynamic_ui/widget/app_bar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/asset_image_widget.dart';
import 'package:rjdu/dynamic_ui/widget/audio_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/baseline_widget.dart';
import 'package:rjdu/dynamic_ui/widget/bottom_navigation_bar_item_widget.dart';
import 'package:rjdu/dynamic_ui/widget/button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/carousel_slider_widget.dart';
import 'package:rjdu/dynamic_ui/widget/checkbox_widget.dart';
import 'package:rjdu/dynamic_ui/widget/custom_scroll_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/flip_card_widget.dart';
import 'package:rjdu/dynamic_ui/widget/gesture_detector_widget.dart';
import 'package:rjdu/dynamic_ui/widget/grid_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/image_widget.dart';
import 'package:rjdu/dynamic_ui/widget/image_network_cached_widget.dart';
import 'package:rjdu/dynamic_ui/widget/center_widget.dart';
import 'package:rjdu/dynamic_ui/widget/circle_avatar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/circular_progress_indicator.dart';
import 'package:rjdu/dynamic_ui/widget/clip_r_rect_widget.dart';
import 'package:rjdu/dynamic_ui/widget/column_widget.dart';
import 'package:rjdu/dynamic_ui/widget/container_widget.dart';
import 'package:rjdu/dynamic_ui/widget/divider_widget.dart';
import 'package:rjdu/dynamic_ui/widget/elevated_button_icon_widget.dart';
import 'package:rjdu/dynamic_ui/widget/expanded_widget.dart';
import 'package:rjdu/dynamic_ui/widget/fitted_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/floating_action_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/icon_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/icon_widget.dart';
import 'package:rjdu/dynamic_ui/widget/image_network.dart';
import 'package:rjdu/dynamic_ui/widget/image_titled_widget.dart';
import 'package:rjdu/dynamic_ui/widget/ink_well_widget.dart';
import 'package:rjdu/dynamic_ui/widget/ink_widget.dart';
import 'package:rjdu/dynamic_ui/widget/limited_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/linear_progress_indicator_widget.dart';
import 'package:rjdu/dynamic_ui/widget/list_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/margin_widget.dart';
import 'package:rjdu/dynamic_ui/widget/material_app_widget.dart';
import 'package:rjdu/dynamic_ui/widget/material_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/material_widget.dart';
import 'package:rjdu/dynamic_ui/widget/raw_material_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/safe_area_widget.dart';
import 'package:rjdu/dynamic_ui/widget/segment_control_widget.dart';
import 'package:rjdu/dynamic_ui/widget/custom/select_sheet.dart';
import 'package:rjdu/dynamic_ui/widget/sized_box_app_bar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/sized_box_bottom_navigation_bar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/sliver_app_bar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/sliver_fill_remaining_widget.dart';
import 'package:rjdu/dynamic_ui/widget/state_widget.dart';
import 'package:rjdu/dynamic_ui/widget/stream_widget.dart';
import 'package:rjdu/dynamic_ui/widget/swipable_stack_widget.dart';
import 'package:rjdu/dynamic_ui/widget/switch_widget.dart';
import 'package:rjdu/dynamic_ui/widget/template_widget.dart';
import 'package:rjdu/dynamic_ui/widget/text_field_widget.dart';
import 'package:rjdu/dynamic_ui/widget/visibility_widget.dart';
import 'package:rjdu/dynamic_ui/widget_property/border_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/box_constraints_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/image_network_cached_provider_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/image_network_provider_property.dart';
import 'package:rjdu/dynamic_ui/widget/notify_widget.dart';
import 'package:rjdu/dynamic_ui/widget/opacity_widget.dart';
import 'package:rjdu/dynamic_ui/widget/overflow_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/padding_widget.dart';
import 'package:rjdu/dynamic_ui/widget/page_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/positioned_widget.dart';
import 'package:rjdu/dynamic_ui/widget/rotated_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/row_widget.dart';
import 'package:rjdu/dynamic_ui/widget/scaffold_widget.dart';
import 'package:rjdu/dynamic_ui/widget/scrollbar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/selectable_text_widget.dart';
import 'package:rjdu/dynamic_ui/widget/sized_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/spacer_widget.dart';
import 'package:rjdu/dynamic_ui/widget/stack_widget.dart';
import 'package:rjdu/dynamic_ui/widget/text_widget.dart';
import 'package:rjdu/dynamic_ui/widget/wrap_widget.dart';
import 'package:rjdu/dynamic_ui/widget_property/border_side_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/box_decoration_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/button_style_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/decoration_image_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/input_decoration_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/linear_gradient_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/outline_input_border_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/rounded_rectangle_border_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/text_style_property.dart';
import 'package:rjdu/dynamic_ui/widget_property/underline_input_border_property.dart';
import 'package:rjdu/util/reference.dart';
import '../util.dart';
import '../util/template.dart';
import 'widget/slidable_widget.dart';

class DynamicUI {
  static Map<String, Function> ui = {
    //Button
    "Button": ButtonWidget().get,
    "ElevatedButtonIcon": ElevatedButtonIconWidget().get,
    "InkWell": InkWellWidget().get,
    "IconButton": IconButtonWidget().get, //Кнопка с иконкой
    "FloatingActionButton": FloatingActionButtonWidget().get, //Кругляш на BottomNavigationBar
    "RawMaterialButton": RawMaterialButtonWidget().get, //Кнопка без фона (можно обернуть в Material)
    "MaterialButton": MaterialButtonWidget().get,
    "AudioButton": AudioButtonWidget().get,

    //Widget
    "MaterialApp": MaterialAppWidget().get,
    "Text": TextWidget().get,
    "Scaffold": ScaffoldWidget().get,
    "SafeArea": SafeAreaWidget().get,
    "AppBar": AppBarWidget().get,
    "SliverAppBar": SliverAppBarWidget().get,
    "SliverFillRemaining": SliverFillRemainingWidget().get,
    "Scrollbar": ScrollbarWidget().get,
    "CustomScrollView": CustomScrollViewWidget().get,
    "ListView": ListViewWidget().get,
    "Notify": NotifyWidget().get,
    "Column": ColumnWidget().get,
    "Row": RowWidget().get,
    "SizedBox": SizedBoxWidget().get,
    "SizedBoxAppBar": SizedBoxAppBarWidget().get,
    "SizedBoxBottomNavigationBar": SizedBoxBottomNavigationBarWidget().get,
    "Expanded": ExpandedWidget().get,
    "Padding": PaddingWidget().get,
    "Margin": MarginWidget().get,
    "Container": ContainerWidget().get,
    "Center": CenterWidget().get,
    "CircleAvatar": CircleAvatarWidget().get,
    "Icon": IconWidget().get,
    "AssetImage": AssetImageWidget().get,
    "Spacer": SpacerWidget().get,
    "SelectableText": SelectableTextWidget().get,
    "BottomNavigationBarItem": BottomNavigationBarItemWidget().get,
    "CircularProgressIndicator": CircularProgressIndicatorWidget().get,
    "PageView": PageViewWidget().get,
    "Align": AlignWidget().get,
    "FittedBox": FittedBoxWidget().get,
    "Baseline": BaselineWidget().get,
    "Stack": StackWidget().get,
    "Positioned": PositionedWidget().get,
    "Opacity": OpacityWidget().get,
    "Wrap": WrapWidget().get,
    "ClipRRect": ClipRRectWidget().get,
    "LimitedBox": LimitedBoxWidget().get,
    "OverflowBox": OverflowBoxWidget().get,
    "Divider": DividerWidget().get,
    "RotatedBox": RotatedBoxWidget().get,
    "ImageNetwork": ImageNetworkWidget().get,
    "ImageNetworkCached": ImageNetworkCachedWidget().get,
    "Visibility": VisibilityWidget().get,
    "Slidable": SlidableWidget().get,
    "GridView": GridViewWidget().get,
    "SegmentControl": SegmentControlWidget().get,
    "Checkbox": CheckboxWidget().get,
    "Ink": InkWidget().get,
    "TextField": TextFieldWidget().get,
    "GestureDetector": GestureDetectorWidget().get,
    "Material": MaterialWidget().get,
    "Template": TemplateWidget().get,
    "State": StateWidget().get,
    "SwipableStack": SwipableStackWidget().get,
    "FlipCard": FlipCardWidget().get,
    "LinearProgressIndicator": LinearProgressIndicatorWidget().get,
    "Image": ImageWidget().get,
    "Stream": StreamWidget().get,
    "CarouselSlider": CarouselSliderWidget().get,
    "ImageTitled": ImageTitledWidget().get,
    "Switch": SwitchWidget().get,

    //Property
    "TextStyle": TextStyleProperty().get,
    "DecorationImage": DecorationImageProperty().get,
    "BoxDecoration": BoxDecorationProperty().get,
    "LinearGradient": LinearGradientProperty().get,
    "ButtonStyle": ButtonStyleProperty().get,
    "RoundedRectangleBorder": RoundedRectangleBorderProperty().get,
    "BorderSide": BorderSideProperty().get,
    "OutlineInputBorder": OutlineInputBorderProperty().get,
    "UnderlineInputBorder": UnderlineInputBorderProperty().get,
    "InputDecoration": InputDecorationProperty().get,
    "ImageNetworkProvider": ImageNetworkProviderProperty().get,
    "ImageNetworkCachedProvider": ImageNetworkCachedProviderProperty().get,
    "BoxConstraints": BoxConstraintsProperty().get,
    "Border": BorderProperty().get,

    //Custom
    "SelectSheet": SelectSheetWidget().get
  };

  static DynamicUIBuilderContext changeContext(
      Map<String, dynamic> parsedJson, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (parsedJson.containsKey("context")) {
      return dynamicUIBuilderContext.cloneWithNewData(
        Util.convertMap(parsedJson["context"]["data"] ?? {}),
        parsedJson["context"]["key"],
      );
    }
    return dynamicUIBuilderContext;
  }

  static dynamic render(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    if (parsedJson.containsKey("pageArgumentsOverlay")) {
      Map<String, dynamic> map = parsedJson["pageArgumentsOverlay"];
      bool needReload = false;
      for (MapEntry<String, dynamic> item in map.entries) {
        if (!dynamicUIBuilderContext.dynamicPage.arguments.containsKey(item.key)) {
          dynamicUIBuilderContext.dynamicPage.arguments[item.key] = item.value;
          needReload = true;
        }
      }
      if (needReload) {
        dynamicUIBuilderContext.dynamicPage.reload(false, "pageSettingsOverlay");
      }
    }
    try {
      if (parsedJson.isEmpty) {
        return defaultValue;
      }
      dynamicUIBuilderContext = changeContext(parsedJson, dynamicUIBuilderContext);
      if (parsedJson.containsKey("debug")) {
        Util.p("DEBUG RENDER (${dynamicUIBuilderContext.linkedNotify}): $parsedJson");
      }
      dynamic selector = (key == null ? parsedJson : ((parsedJson.containsKey(key)) ? parsedJson[key] : defaultValue));
      if (selector.runtimeType.toString().contains("Map<String,") && selector.containsKey("flutterType")) {
        selector = Util.getMutableMap(selector);
        Reference.compileReferenceList(selector, dynamicUIBuilderContext);
        Template.compileTemplateList(selector, dynamicUIBuilderContext);

        if (selector.containsKey("onStateDataUpdate")) {
          String state = selector["onStateDataUpdateKey"] ?? selector["state"] ?? "main";
          String keyMapLink = "state${Util.capitalize(state)}";
          if (selector.containsKey("link")) {
            Map<String, dynamic> mapLink = selector["link"] as Map<String, dynamic>;
            mapLink[keyMapLink] = dynamicUIBuilderContext.dynamicPage.stateData.getInstanceData(state).uuid;
          } else {
            selector["link"] = {keyMapLink: dynamicUIBuilderContext.dynamicPage.stateData.getInstanceData(state).uuid};
          }
          selector.remove("onStateDataUpdate");
        }

        if (selector["flutterType"] != "Notify" && selector.containsKey("link")) {
          // Selector это наш шаблон, но мы хотим сделать его зависимым от link данных в DataSource
          // Клонируем selector, что бы удалить блок link, иначе он зациклится в этом месте
          Map<String, dynamic> cloneTemplate = {};
          cloneTemplate.addAll(selector);
          cloneTemplate.remove("link");
          cloneTemplate.remove("context");

          Map<String, dynamic> contextData =
              selector.containsKey("context") ? selector["context"] : {"key": "DynamicUITransform", "data": {}};
          contextData["data"]["template"] = cloneTemplate;

          Map<String, dynamic> renderData = {
            "flutterType": "Notify",
            "link": selector["link"],
            "context": contextData,
          };
          return render(renderData, null, defaultValue, dynamicUIBuilderContext);
        } else {
          String flutterType = selector["flutterType"] as String;
          return ui.containsKey(flutterType)
              ? Function.apply(ui[flutterType]!, [selector, dynamicUIBuilderContext])
              : (defaultValue ?? Text("[DynamicUI.get() Undefined type: $flutterType]"));
        }
      }
      return selector;
    } catch (error, stackTrace) {
      Util.log("DynamicUI.render() parsedJson: $parsedJson; Error: $error", stackTrace: stackTrace, type: "error");
      return Text(error.toString());
    }
  }

  static List<Widget> renderList(
      Map<String, dynamic> parsedJson, String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<Widget> resultList = [];
    List list = parsedJson[key] ?? [];
    if (list.runtimeType.toString().contains("List")) {
      for (int i = 0; i < list.length; i++) {
        resultList.add(render(list[i], null, const SizedBox(), dynamicUIBuilderContext));
      }
    }
    return resultList;
  }
}
