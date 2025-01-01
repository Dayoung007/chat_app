import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:new_chat_app/utilities/global_method.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSeccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;

  bool get isSeccessful => _isSeccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get getUserModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //signin with phone number
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
          _isSeccessful = false;
          notifyListeners();
       showSnackBar(context, e.message!);
        },
        codeSent: (String verificationId, int? resendToken) {

          _isLoading = false;
          notifyListeners();
          // Navigate to OTP verification screen
          print('navigate to OTP verification screen');


        },
        codeAutoRetrievalTimeout: (String verificationId) {
        },
      );
    } catch (e) {
      _isLoading = false;
      _isSeccessful = false;
      notifyListeners();
      // Handle any other errors
    }
  }
}
