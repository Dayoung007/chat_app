import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_chat_app/utilities/assets_manager.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({
    super.key,
    required this.onPress,
    this.finalFileImage,
    required this.isImageFile,
  });

  final Function()? onPress;
  final File? finalFileImage;
  final bool isImageFile;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = isImageFile && finalFileImage != null
        ? Image.file(
            finalFileImage!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          )
        : Image.asset(
            AssetsManager.userImage,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(200),
          clipBehavior: Clip.antiAlias,
          child: imageWidget,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPress,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
