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
  bool? _isSuccessfulOtp;

  bool? get isSuccessfulOtp => _isSuccessfulOtp;

  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get getUserModel => _userModel;
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //check authentication state
  Future<bool> checkAuthenticationState() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _uid = user.uid;
      _phoneNumber = user.phoneNumber;
      await getUserDataFromFirestore();
      await saveUserDataToSharedPreferences();
      return true;
    } else {
      _uid = null;
      _phoneNumber = null;
      _userModel = null;
      return false;
    }
  }

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
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(_uid)
          .get();

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

  ///save user data to shared preferences

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      Constants.userModel,
      jsonEncode(
        _userModel?.toMap(),
      ),
    );
  }

  //get data from shares preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    String userModelString =
    sharedPreferences.getString(Constants.userModel)!;
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel?.uid;
    notifyListeners();
  }

  Future<void> signInWithPhoneNumber({required String phoneNumber,
    required BuildContext context}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted:
            (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          _isSuccessful = false;
          notifyListeners();
          showSnackBar(context, e.message!);
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          _isSuccessfulOtp = false;
          notifyListeners();
          showSnackBar(
              context, 'navigate to OTP verification screen');

          Navigator.of(context)
              .pushNamed(Constants.otpScreen, arguments: {
            Constants.phoneNumber: phoneNumber,
            Constants.verificationId: verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _isLoading = false;
          _isSuccessful = false;
          _isSuccessfulOtp = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _isSuccessfulOtp = false;
      _isSuccessful = false;
      notifyListeners();
    }
  }

  void navigateToTheOtpScreen(BuildContext context,
      String verificationId,) {}

  Future<void> checkInitialOtpState() async {
    _isSuccessfulOtp = true;
    notifyListeners();
  }

  Future<void> verifyOtpCode({
    required String verificationId,
    required String otpCode,
    required Function onSuccess,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      _isSuccessful = false;
      _isSuccessfulOtp = false;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Access the user details safely
      final User? user = userCredential.user;
      if (user != null) {
        _uid = user.uid;
        _phoneNumber = user.phoneNumber;
        _isSuccessful = false;
        _isSuccessfulOtp = false;
       await onSuccess();
        _isSuccessful = true;
        _isSuccessfulOtp = true;
        notifyListeners();

      } else {
        throw Exception('User is null after signing in.');
      }
    } catch (error) {
      _isSuccessful = false;
      _isSuccessfulOtp = false;

      showSnackBar(context,
          "Error type: ${error.runtimeType}, message: ${error
              .toString()}");

      if (error is FirebaseAuthException) {
        showSnackBar(
            context, 'Firebase Auth Error: ${error.message}');
      } else {
        showSnackBar(
            context, 'Unexpected Error: ${error.toString()}');
      }
      notifyListeners();
    } finally {
      _isLoading = false;
      _isSuccessfulOtp = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      _isLoading = false;
      _isSuccessfulOtp = false;
      notifyListeners();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Handle automatic verification
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Save the verification ID for later use
          // You might want to update the state or notify listeners here
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
            file: fileImage,
            reference: '${Constants.userImages}/${userModel.uid}');
        userModel.image = imageUrl;
      }
      userModel.lastSeen =
          DateTime
              .now()
              .millisecondsSinceEpoch
              .toString();
      userModel.createdAt =
          DateTime
              .now()
              .millisecondsSinceEpoch
              .toString();

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
    UploadTask uploadTask =
    _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  // get user stream
  Stream<DocumentSnapshot> usersStream({required String userId}) =>
      _firestore.collection(Constants.users).doc(userId).snapshots();

//send friend request

  Future<void> sendFriendRequest({
    required String friendId,
  }) async {
    try {
      // add uid to friend request list
      await _firestore
          .collection(Constants.users)
          .doc(friendId)
          .update({
        Constants.friendRequestUids: FieldValue.arrayUnion([_uid]),
      });
      // add uid to friend request sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestUids:
        FieldValue.arrayUnion([friendId])
      });
      notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }


  Future<void> acceptOrDeclineFriendRequest({
    required String friendId,
    required bool accept

  }) async {
    if (accept) {
      await acceptFriendRequest(friendId: friendId);
    } else {
      await declineFriendRequest(friendId: friendId);
    }
  }

  Future<void> acceptFriendRequest({
    required String friendId,
  }) async {
    try {
      // add uid to friend list
      await _firestore
          .collection(Constants.users)
          .doc(friendId)
          .update({
        Constants.friendUids: FieldValue.arrayUnion([_uid])
      });
      // add uid to friend list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendUids: FieldValue.arrayUnion([friendId])
      });

      await _firestore
          .collection(Constants.users)
          .doc(friendId)
          .update({
        Constants.sentFriendRequestUids: FieldValue.arrayRemove(
            [_uid])
      });
      // Remove friend's ID from current user's sent friend request list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendRequestUids:
        FieldValue.arrayRemove([friendId])
      });
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }


  Future<void> declineFriendRequest({
    required String? friendId,
  }) async {
    try {
      // Remove uid from friend's friend request list
      await _firestore
          .collection(Constants.users)
          .doc(friendId)
          .update({
        Constants.sentFriendRequestUids: FieldValue.arrayRemove(
            [_uid])
      });
      // Remove friend's ID from current user's sent friend request list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendRequestUids:
        FieldValue.arrayRemove([friendId])
      });
    } on FirebaseException catch (e) {
      print("Error canceling friend request: ${e.message}");
    }
  }

  Future<void> cancelFriendRequest({
    required String? friendId,
  }) async {
    try {
      // Remove uid from friend's friend request list
      await _firestore
          .collection(Constants.users)
          .doc(friendId)
          .update({
        Constants.friendRequestUids: FieldValue.arrayRemove([_uid])
      });
      // Remove friend's ID from current user's sent friend request list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestUids:
        FieldValue.arrayRemove([friendId])
      });
    } on FirebaseException catch (e) {
      print("Error canceling friend request: ${e.message}");
    }
  }


  Future<void> unFriend({required String friendId}) async {
    try {
      await _firestore
          .collection(Constants.users)
          .doc(friendId)
          .update({
        Constants.friendUids: FieldValue.arrayRemove([_uid])
      });
      // Remove friend's ID from current user's sent friend request list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendUids:
        FieldValue.arrayRemove([friendId])
      });
    } on FirebaseException catch (e) {
      print("Error unfriending  friend : ${e.message}");
    }
  }

  // get all users stream
  Stream<QuerySnapshot> getAllUsersStream({required String userId}) =>
      _firestore
          .collection(Constants.users)
          .where(Constants.uid, isNotEqualTo: userId)
          .snapshots();


  //get list of friends
  Future<List<UserModel>> getFriendsList(String uid) async {
    List<UserModel> friends = [];

    // Fetch user document
    DocumentSnapshot docSnapshot =
    await _firestore.collection(Constants.users).doc(uid).get();

    // Explicitly cast friendUids to List<String>
    List<String> friendUids = List<String>.from(docSnapshot.get(Constants.friendUids));

    // Loop through friendUids to fetch user details
    for (String friendUid in friendUids) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendUid)
          .get();

      // Parse and add friend details to the list
      UserModel friend = UserModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>
      );
      friends.add(friend);
    }

    return friends;
  }

  //get list of friend requests
  Future<List<UserModel>> getFriendRequestList(String uid) async {
    List<UserModel> friendRequests = [];

    try {
      // Fetch user document
      DocumentSnapshot docSnapshot =
      await _firestore.collection(Constants.users).doc(uid).get();

      // Get friend request UIDs as a list of strings
      List<String> friendRequestUids =
      List<String>.from(docSnapshot.get(Constants.friendRequestUids) ?? []);

      // Fetch all friend details concurrently
      List<Future<UserModel>> friendRequestFutures = friendRequestUids.map((friendRequestUid) async {
        DocumentSnapshot documentSnapshot = await _firestore
            .collection(Constants.users)
            .doc(friendRequestUid)
            .get();
        return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      }).toList();

      // Wait for all requests to complete and collect results
      friendRequests = await Future.wait(friendRequestFutures);
    } catch (e) {
      print("Error fetching friend requests: $e");
      // Handle error or return an empty list
    }

    return friendRequests;
  }

  Future<void> logout() async {
      await _auth.signOut();
      _uid = null;
      _phoneNumber = null;
      _userModel = null;
      SharedPreferences shared = await SharedPreferences
          .getInstance();
      await shared.clear();
      notifyListeners();
    }


//
  }
