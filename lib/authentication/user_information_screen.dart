import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/widget/app_button.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


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
    cropImage(finalFileImage?.path);
    
  }
  void popContext() {
    Navigator.of(context).pop();
  }

void cropImage(filePath) async {
    try {
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
    }}catch (e){
      print(
        'this is $e'

      );
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
        child: Form(
          key: _formKey,
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
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value!.isEmpty  || value.length < 3) {
                    return 'Name should be at least 3 characters long';
                  } else {
                    return null;
                  }
                },
    onChanged: (value) {
      _nameController.text = value;
    },
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
          
                    if (_formKey.currentState!.validate()) {
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

    // Trim and store the name
    final String userName = _nameController.text.trim();

    // Reference Firestore
    final firestore = _authProvider.firestore;

    // Check if the name exists
    final querySnapshot = await firestore
        .collection(Constants.users) // Replace with your Firestore collection name
        .where(Constants.name, isEqualTo: userName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Username already exists
      showSnackBar(context, 'This username is already taken. Please choose another.');
      return;
    }

    // Username doesn't exist, proceed to save
    UserModel userModel = UserModel(
      name: userName,
      uid: _authProvider.uid!,
      phoneNumber: _authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I am using this application',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendUids: [],
      friendRequestUids: [],
      sentFriendRequestUids: [],
    );

    // Save user data to Firestore
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
      },
    );
  }


  void navigateToHomeScreen() {
    // Navigate to home screen and remove all routes

    Navigator.of(context).pushNamedAndRemoveUntil(Constants.homeScreen, (route) => false);
  }
}


