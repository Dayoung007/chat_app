//show snack bar method
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_chat_app/utilities/assets_manager.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

Future<File?> pickImage(
    {required bool fromCamera, required Function(String) onFail}) async {
  File? fileImage;
  try {
    final pickedFile = await ImagePicker()
        .pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedFile == null) {
      onFail('Failed to get image');
      return null;
    } else {
      fileImage = File(pickedFile.path);
    }
  } catch (e) {
    onFail(fromCamera
        ? 'Failed to get image from camera'
        : 'Failed to get image from gallery');
    return null;
  }
  return fileImage;
}

Widget userImageWidget(
        {required String? imageUrl, required double radius, required Function()? onTap}) =>



    GestureDetector(
      onTap: onTap,
      child: CircleAvatar(

        radius: radius,
        backgroundImage:
            imageUrl == '' ? AssetImage(AssetsManager.userImage) : NetworkImage(imageUrl!),
      ),
    );
