import 'package:flutter/material.dart';
import 'package:rjdu/dynamic_ui/dynamic_ui_builder_context.dart';
import 'package:rjdu/dynamic_ui/widget/align_widget.dart';
import 'package:rjdu/dynamic_ui/widget/app_bar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/asset_image_widget.dart';
import 'package:rjdu/dynamic_ui/widget/baseline_widget.dart';
import 'package:rjdu/dynamic_ui/widget/bottom_navigation_bar_item_widget.dart';
import 'package:rjdu/dynamic_ui/widget/button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/checkbox_widget.dart';
import 'package:rjdu/dynamic_ui/widget/custom_scroll_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/gesture_detector_widget.dart';
import 'package:rjdu/dynamic_ui/widget/grid_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/image_network_cached_widget.dart';
import 'package:rjdu/dynamic_ui/widget/center_widget.dart';
import 'package:rjdu/dynamic_ui/widget/circle_avatar_widget.dart';
import 'package:rjdu/dynamic_ui/widget/circular_progress_indicator.dart';
import 'package:rjdu/dynamic_ui/widget/clip_r_rect_widget.dart';
import 'package:rjdu/dynamic_ui/widget/column_widget.dart';
import 'package:rjdu/dynamic_ui/widget/container_widget.dart';
import 'package:rjdu/dynamic_ui/widget/divider_widget.dart';
import 'package:rjdu/dynamic_ui/widget/elevated_button_icon_widget.dart';
import 'package:rjdu/dynamic_ui/widget/elevated_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/expanded_widget.dart';
import 'package:rjdu/dynamic_ui/widget/fitted_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/floating_action_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/icon_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/icon_widget.dart';
import 'package:rjdu/dynamic_ui/widget/image_network.dart';
import 'package:rjdu/dynamic_ui/widget/ink_well_widget.dart';
import 'package:rjdu/dynamic_ui/widget/ink_widget.dart';
import 'package:rjdu/dynamic_ui/widget/limited_box_widget.dart';
import 'package:rjdu/dynamic_ui/widget/list_view_widget.dart';
import 'package:rjdu/dynamic_ui/widget/margin_widget.dart';
import 'package:rjdu/dynamic_ui/widget/material_app_widget.dart';
import 'package:rjdu/dynamic_ui/widget/material_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/material_widget.dart';
import 'package:rjdu/dynamic_ui/widget/raw_material_button_widget.dart';
import 'package:rjdu/dynamic_ui/widget/segment_control_widget.dart';
import 'package:rjdu/dynamic_ui/widget/template_widget.dart';
import 'package:rjdu/dynamic_ui/widget/text_field_widget.dart';
import 'package:rjdu/dynamic_ui/widget/visibility_widget.dart';
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
import 'widget/slidable_widget.dart';

class DynamicUI {
  static Map<String, Function> ui = {
    //Button
    'Button': ButtonWidget().get,
    'ElevatedButtonIcon': ElevatedButtonIconWidget().get,
    'ElevatedButton': ElevatedButtonWidget().get,
    'InkWell': InkWellWidget().get,
    'IconButton': IconButtonWidget().get,
    'FloatingActionButton': FloatingActionButtonWidget().get,
    'RawMaterialButton': RawMaterialButtonWidget().get,

    //Widget
    "MaterialApp": MaterialAppWidget().get,
    "Text": TextWidget().get,
    "Scaffold": ScaffoldWidget().get,
    'AppBar': AppBarWidget().get,
    'Scrollbar': ScrollbarWidget().get,
    'CustomScrollView': CustomScrollViewWidget().get,
    'ListView': ListViewWidget().get,
    'Notify': NotifyWidget().get,
    'Column': ColumnWidget().get,
    'Row': RowWidget().get,
    'SizedBox': SizedBoxWidget().get,
    'Expanded': ExpandedWidget().get,
    'Padding': PaddingWidget().get,
    'Margin': MarginWidget().get,
    'Container': ContainerWidget().get,
    'Center': CenterWidget().get,
    'CircleAvatar': CircleAvatarWidget().get,
    'Icon': IconWidget().get,
    'AssetImage': AssetImageWidget().get,
    'Spacer': SpacerWidget().get,
    'SelectableText': SelectableTextWidget().get,
    'BottomNavigationBarItem': BottomNavigationBarItemWidget().get,
    'CircularProgressIndicator': CircularProgressIndicatorWidget().get,
    'PageView': PageViewWidget().get,
    'Align': AlignWidget().get,
    'FittedBox': FittedBoxWidget().get,
    'Baseline': BaselineWidget().get,
    'Stack': StackWidget().get,
    'Positioned': PositionedWidget().get,
    'Opacity': OpacityWidget().get,
    'Wrap': WrapWidget().get,
    'ClipRRect': ClipRRectWidget().get,
    'LimitedBox': LimitedBoxWidget().get,
    'OverflowBox': OverflowBoxWidget().get,
    'Divider': DividerWidget().get,
    'RotatedBox': RotatedBoxWidget().get,
    'ImageNetwork': ImageNetworkWidget().get,
    'ImageNetworkCached': ImageNetworkCachedWidget().get,
    'Visibility': VisibilityWidget().get,
    'Slidable': SlidableWidget().get,
    'GridView': GridViewWidget().get,
    'SegmentControl': SegmentControlWidget().get,
    'Checkbox': CheckboxWidget().get,
    'Ink': InkWidget().get,
    'TextField': TextFieldWidget().get,
    'GestureDetector': GestureDetectorWidget().get,
    'Material': MaterialWidget().get,
    'MaterialButton': MaterialButtonWidget().get,
    'Template': TemplateWidget().get,

    //Property
    'TextStyle': TextStyleProperty().get,
    'DecorationImage': DecorationImageProperty().get,
    'BoxDecoration': BoxDecorationProperty().get,
    'LinearGradient': LinearGradientProperty().get,
    'ButtonStyle': ButtonStyleProperty().get,
    'RoundedRectangleBorder': RoundedRectangleBorderProperty().get,
    'BorderSide': BorderSideProperty().get,
    'OutlineInputBorder': OutlineInputBorderProperty().get,
    'UnderlineInputBorder': UnderlineInputBorderProperty().get,
    'InputDecoration': InputDecorationProperty().get,
    'ImageNetworkProvider': ImageNetworkProviderProperty().get,
    'ImageNetworkCachedProvider': ImageNetworkCachedProviderProperty().get,
    'BoxConstraints': BoxConstraintsProperty().get,
  };

  static dynamic render(
    Map<String, dynamic> parsedJson,
    String? key,
    dynamic defaultValue,
    DynamicUIBuilderContext dynamicUIBuilderContext,
  ) {
    if (parsedJson.isEmpty) {
      return defaultValue;
    }
    dynamic selector = key == null ? parsedJson : ((parsedJson.containsKey(key)) ? parsedJson[key] : defaultValue);
    if (selector.runtimeType.toString().contains('Map<String,') && selector.containsKey('flutterType')) {
      if (selector.containsKey('onStateDataUpdate')) {
        if (selector.containsKey('link')) {
          Map<String, dynamic> mapLink = selector['link'] as Map<String, dynamic>;
          mapLink['stateData'] = dynamicUIBuilderContext.dynamicPage.uuid;
        } else {
          selector['link'] = {'stateData': dynamicUIBuilderContext.dynamicPage.uuid};
        }
        selector.remove('onStateDataUpdate');
      }

      if (selector['flutterType'] != 'Notify' && selector.containsKey('link')) {
        //Клонируем selector, что бы удалить блок link
        Map<String, dynamic> cloneTemplate = {};
        cloneTemplate.addAll(selector);
        cloneTemplate.remove('link');
        //То есть мы будем получать данные из DataSource по указанным uuid из link
        //Шаблон именно в этом случаи не будет получаться из DataSource, поэтому мы его поместим в значения по умолчанию в linkDefault
        Map<String, dynamic> linkDefault = {'template': cloneTemplate};
        if (selector.containsKey('linkDefault')) {
          linkDefault.addAll(selector['linkDefault']);
        }
        return render(
          {'flutterType': 'Notify', 'link': selector['link'], 'linkDefault': linkDefault},
          null,
          defaultValue,
          dynamicUIBuilderContext,
        );
      } else {
        String flutterType = selector['flutterType'] as String;
        return ui.containsKey(flutterType)
            ? Function.apply(ui[flutterType]!, [selector, dynamicUIBuilderContext])
            : (defaultValue ?? Text("[DynamicUI.get() Undefined type: $flutterType]"));
      }
    }
    return selector;
  }

  static List<Widget> renderList(Map<String, dynamic> parsedJson, String key, DynamicUIBuilderContext dynamicUIBuilderContext) {
    List<Widget> resultList = [];
    List list = parsedJson[key] ?? [];
    if (list.runtimeType.toString().contains('List')) {
      if (parsedJson.containsKey("newContext") && parsedJson["newContext"] == false) {
        for (int i = 0; i < list.length; i++) {
          resultList.add(render(list[i], null, const SizedBox(), dynamicUIBuilderContext));
        }
      } else {
        for (int i = 0; i < list.length; i++) {
          DynamicUIBuilderContext newContext = parsedJson[key][i]["context"] != null
              ? dynamicUIBuilderContext.cloneWithNewData(parsedJson[key][i]["context"])
              : dynamicUIBuilderContext.clone();
          newContext.index = i;
          newContext.key = key;
          resultList.add(render(list[i], null, const SizedBox(), newContext));
        }
      }
    }
    return resultList;
  }
}
