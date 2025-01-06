import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/widget/display_user_image.dart';
import 'package:provider/provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  void selectImage(
    bool fromCamera,
  ) async {
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (String message) {
          showSnackBar(context, message);
        });
    // crop image
    await cropImage(finalFileImage?.path);
    popContext();
  }
  void popContext() {
    Navigator.of(context).pop();
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: filePath, maxHeight: 800, maxWidth: 800, compressQuality: 90);
      popTheDialog();
      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      } else {
        popTheDialog();
      }
    }
  }

  void popTheDialog() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: finalFileImage != null
                  ? DisplayUserImage(
                      onPress: () {
                        buildShowModalBottomSheet(context);
                      },
                      isImageFile: true,
                      finalFileImage: finalFileImage,
                    )
                  : DisplayUserImage(
                      onPress: () {
                        buildShowModalBottomSheet(context);
                      },
                      isImageFile: false,
                    ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              action: () {
                if (_nameController.text.isEmpty || _nameController.text.length < 3) {
                  showSnackBar(context, 'Name should be at least 3 characters long');
                  return;
                } else {
                  saveUserDataToFirestore();
                }
                //save the user to firestore
              },
              buttonText: 'Continue',
              textColor: Colors.white,
              buttonBackground: Colors.blueAccent,
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        showDragHandle: true,
        backgroundColor: Colors.white,
        elevation: 10,
        context: context,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height / 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                ListTile(
                  onTap: () {
                    selectImage(true);
                  },
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () {
                    selectImage(false);
                  },
                  leading: const Icon(Icons.photo_library),
                  title: Text('Gallery'),
                ),
              ],
            ),
          );
        });
  }

  // save user data to firestore
  Future<void> saveUserDataToFirestore() async {
    final _authProvider = context.read<AuthenticationProvider>();
    UserModel userModel = UserModel(
        name: _nameController.text.trim(),
        uid: _authProvider.uid!,
        phoneNumber: _authProvider.phoneNumber!,
        image: '',
        token: '',
        aboutMe: 'Hey there, i am using this application',
        lastSeen: '',
        createdAt: '',
        isOnline: true,
        friendUids: [],
        friendRequestUids: [],
        sentFriendRequestUids: []);

    _authProvider.saveUserDataToFirestore(
        userModel: userModel,
        fileImage: finalFileImage,
        onSuccess: () async {
          showSnackBar(context, 'User data saved successfully');
          await Future.delayed(const Duration(seconds: 1));
          await _authProvider.saveUserDataToSharedPreferences();
          navigateToHomeScreen();
        },
        onFail: () async {
          showSnackBar(context, 'Failed to save user data');
          await Future.delayed(const Duration(seconds: 1));
        });
  }

  void navigateToHomeScreen() {
    // Navigate to home screen and remove all routes

    Navigator.of(context).pushNamedAndRemoveUntil(Constants.homeScreen, (route) => false);
  }
}

class AppButton extends StatelessWidget {
  const AppButton(
      {Key? key,
      required this.action,
      required this.buttonText,
      required this.buttonBackground,
      required this.textColor,
      this.splashColor})
      : super(key: key);

  final Function()? action;
  final String buttonText;
  final Color buttonBackground;
  final Color textColor;
  final Color? splashColor;

  @override
  Widget build(BuildContext context) {
    // Button splash color
    Color buttonSplashColor = splashColor ?? buttonBackground;
    // Return button component
    return TextButton(
      onPressed: action,
      style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: WidgetStatePropertyAll(buttonSplashColor)),
      child: Container(
        alignment: Alignment.center,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: buttonBackground,
        ),
        child: Text(buttonText,
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ),
    );
  }
}
