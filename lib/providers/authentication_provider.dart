import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get getUserModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //check if user exists
  Future<bool> isUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  //get user dats from firestore
  Future<void> getUserDataFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(Constants.users).doc(_uid).get();

      if (!documentSnapshot.exists) {
        print("User document does not exist for uid: $_uid");
        return;
      }

      var data = documentSnapshot.data();
      if (data == null) {
        print("Document data is null for uid: $_uid");
        return;
      }

      if (data is! Map<String, dynamic>) {
        print("Unexpected data type: ${data.runtimeType}");
        return;
      }

      _userModel = UserModel.fromMap(data);
      print('this is the $data');


      notifyListeners();
    } catch (e) {
      print("Error getting user data from Firestore: $e");
      // Handle the error appropriately
    }
  }

  //save user data to shared preferences

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      Constants.userModel,
      jsonEncode(
        _userModel?.toMap(),
      ),
    );
  }

  //get data from shares preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString(Constants.userModel)!;
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel?.uid;
    notifyListeners();
  }

  Future<void> signInWithPhoneNumber(
      {required String phoneNumber, required BuildContext context}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          _isSuccessful = false;
          notifyListeners();
          showSnackBar(context, e.message!);
        },
        codeSent: (String verificationId, int? resendToken) {
          _isLoading = false;
          notifyListeners();
          print('navigate to OTP verification screen');
          Navigator.of(context).pushNamed(Constants.otpScreen, arguments: {
            Constants.phoneNumber: phoneNumber,
            Constants.verificationId: verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _isLoading = false;
      _isSuccessful = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtpCode({
    required String verificationId,
    required String otpCode,
    required Function onSuccess,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print('UserCredential runtimeType: ${userCredential.runtimeType}');
      print('User: ${userCredential.user}');
      print('AdditionalUserInfo: ${userCredential.additionalUserInfo}');

      // Access the user details safely
      final User? user = userCredential.user;
      if (user != null) {
        _uid = user.uid;
        _phoneNumber = user.phoneNumber;
        _isSuccessful = true;
        onSuccess();
      } else {
        throw Exception('User is null after signing in.');
      }
    } catch (error) {
      _isSuccessful = false;
      print("Error type: ${error.runtimeType}, message: ${error.toString()}");

      if (error is FirebaseAuthException) {
        showSnackBar(context, 'Firebase Auth Error: ${error.message}');
      } else {
        showSnackBar(context, 'Unexpected Error: ${error.toString()}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

//sign user data to firestore
  void saveUserDataToFirestore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (fileImage != null) {
        String imageUrl = await storeFileToStorage(
            file: fileImage, reference: '${Constants.userImages}/${userModel.uid}');
        userModel.image = imageUrl;
      }
      userModel.lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();

      _userModel = userModel;

      ///save user data to firestore

      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());
      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }

    await _firestore
        .collection(Constants.users)
        .doc(userModel.uid)
        .set(userModel.toMap());
  }

// store image to storage and returen file url
  Future<String> storeFileToStorage(
      {required File file, required String reference}) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }
}
