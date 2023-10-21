import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rjdu/dynamic_invoke/handler/data_source_set_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/system_notify_handler.dart';
import 'package:rjdu/dynamic_invoke/handler_custom/custom_loader_open_handler.dart';
import 'package:rjdu/system_notify.dart';
import 'package:rjdu/theme_provider.dart';

import '../../dynamic_ui/widget/abstract_widget.dart';
import '../../util.dart';
import '../dynamic_invoke.dart';
import 'abstract_handler.dart';
import '../../dynamic_ui/dynamic_ui_builder_context.dart';
import 'dart:io';
import 'dart:convert';

class ShowHandler extends AbstractHandler {
  @override
  handle(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) {
    if (Util.containsKeys(args, ["case"])) {
      switch (args["case"]) {
        case "bottomNavigationBar":
          DynamicInvoke().sysInvokeType(
            SystemNotifyHandler,
            {
              "SystemNotifyEnum": SystemNotifyEnum.changeBottomNavigationTab.name,
              "state": "true",
            },
            dynamicUIBuilderContext,
          );
          break;
        case "actionButton":
          DynamicInvoke().sysInvokeType(
            DataSourceSetHandler,
            {
              "uuid": "FloatingActionButton.json",
              "type": "virtual",
              "value": Util.getMutableMap(args["template"]),
            },
            dynamicUIBuilderContext,
          );
          break;
        case "customLoader":
          DynamicInvoke().sysInvokeType(CustomLoaderOpenHandler, args, dynamicUIBuilderContext);
          break;
        case "gallery":
          openGallery(args, dynamicUIBuilderContext);
          break;
        default:
          Util.p("HideHandler default case: $args");
          break;
      }
    } else {
      Util.p("HideHandler not contains Keys: [case] in args: $args");
    }
  }

  static dynamic openGallery(Map<String, dynamic> args, DynamicUIBuilderContext dynamicUIBuilderContext) async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        cropStyle: CropStyle.rectangle,
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "",
            toolbarColor: ThemeProvider.projectPrimary,
            toolbarWidgetColor: ThemeProvider.projectPrimaryText,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: "",
            hidesNavigationBar: true,
            aspectRatioPickerButtonHidden: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: true,
            resetAspectRatioEnabled: false,
            cancelButtonTitle: "Отмена",
            doneButtonTitle: "Готово",
            aspectRatioLockDimensionSwapEnabled: true,
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (croppedFile != null) {
        File file = File(croppedFile.path);
        String base64Image = base64Encode(file.readAsBytesSync());
        if (args.containsKey("onLoadImage")) {
          Map<String, dynamic> onLoadImage = Util.getMutableMap(args["onLoadImage"]);
          if (onLoadImage.containsKey("args")) {
            onLoadImage["args"]["ImageData"] = base64Image;
          } else {
            onLoadImage["args"] = {"ImageData": base64Image};
          }
          AbstractWidget.clickStatic({"onLoadImage": onLoadImage}, dynamicUIBuilderContext, "onLoadImage");
        } else {
          Util.p("onLoad arguments does not exist");
        }
      }
    }
  }
}
