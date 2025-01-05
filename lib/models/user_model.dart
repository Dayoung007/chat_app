import 'package:new_chat_app/constant.dart';

class UserModel {
  String name;
  String uid;
  String phoneNumber;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String createdAt;
  bool isOnline;
  List<String> friendUids;
  List<String> friendRequestUids;
  List<String> sentFriendRequestUids;

  UserModel(
      {required this.name,
        required this.uid,
      required this.phoneNumber,
      required this.image,
      required this.token,
      required this.aboutMe,
      required this.lastSeen,
      required this.createdAt,
      required this.isOnline,
      required this.friendUids,
      required this.friendRequestUids,
      required this.sentFriendRequestUids});

//from map
factory UserModel.fromMap(Map<String, dynamic> map) =>
  UserModel(
    name: map[Constants.name] ?? '',
    uid: map[Constants.uid] ?? '',
    phoneNumber: map[Constants.phoneNumber] ?? '',
    image: map[Constants.image] ?? '',
    token: map[Constants.token] ?? '',
    aboutMe: map[Constants.aboutMe] ?? '',
    lastSeen: map[Constants.lastSeen] ?? '',
    createdAt: map[Constants.createdAt] ?? '',
    isOnline: map[Constants.isOnline] ?? false,
    friendUids: List<String>.from(map[Constants.friendUids] ?? []),
    friendRequestUids: List<String>.from(map[Constants.friendRequestUids] ?? []),
    sentFriendRequestUids: List<String>.from(map[Constants.sentFriendRequestUids] ?? []),
  );

  

  //to map
Map<String, dynamic> toMap() {
  return {
    Constants.name: name,
    Constants.uid: uid,
    Constants.phoneNumber: phoneNumber,
    Constants.image: image,
    Constants.token: token,
    Constants.aboutMe: aboutMe,
    Constants.lastSeen: lastSeen,
    Constants.createdAt: createdAt,
    Constants.isOnline: isOnline,
    Constants.friendUids: friendUids,
    Constants.friendRequestUids: friendRequestUids,
    Constants.sentFriendRequestUids: sentFriendRequestUids,
  };
}


}
