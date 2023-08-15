import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rjdu/dynamic_invoke/handler/data_source_set_handler.dart';
import 'package:rjdu/dynamic_invoke/handler/system_notify_handler.dart';
import 'package:rjdu/dynamic_invoke/handler_custom/custom_loader_open_handler.dart';
import 'package:rjdu/system_notify.dart';

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
          openGallery();
          break;
        default:
          if (kDebugMode) {
            print("HideHandler default case: $args");
          }
          break;
      }
    } else {
      if (kDebugMode) {
        print("HideHandler not contains Keys: [case] in args: $args");
      }
    }
  }

  static dynamic openGallery() async {
    print("OPEN GALLERY");

    var image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Редактировать',
              toolbarColor: Colors.blue[600],
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true),
          IOSUiSettings(
              title: 'Редактировать',
              hidesNavigationBar: true,
              aspectRatioPickerButtonHidden: true,
              rotateButtonsHidden: true,
              rotateClockwiseButtonHidden: true,
              resetAspectRatioEnabled: false),
        ],
      );
      if (croppedFile != null) {
        File file = File(croppedFile.path);
        String base64Image = base64Encode(file.readAsBytesSync());
        print(base64Image);
        //await Util.uploadImage(File(croppedFile.path), "${GlobalData.host}${data["url"]}");
        //appStoreData.onIndexRevisionError();
      }
    }
    //print("IMAGE: ${image}");
  }
}
