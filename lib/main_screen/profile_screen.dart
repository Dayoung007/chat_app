import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:new_chat_app/widget/app_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>();

    //get data from current user

    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar:
          AppBar(centerTitle: true, title: Text('Profile'), actions: [
        currentUser.uid == uid
            ? IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async {
                  Navigator.pushNamed(
                    context,
                    Constants.settingScreen,
                    arguments: uid,
                  );
                },
              )
            : SizedBox()
      ]),
      body: StreamBuilder<DocumentSnapshot>(
        stream: context
            .read<AuthenticationProvider>()
            .usersStream(userId: uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text("User not found");
          }
          final userModel = UserModel.fromMap(
              snapshot.data!.data() as Map<String, dynamic>);

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              userImageWidget(
                imageUrl: userModel.image,
                radius: 70,
                onTap: () {},
              ),
              SizedBox(height: 15),
              Text(
                userModel.name.toUpperCase(),
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildFriendRequestButton(
                    currentUser: currentUser,
                    userModel: userModel,
                  ),
                  SizedBox(height: 15),
                  buildFriendsButton(
                    currentUser: currentUser,
                    userModel: userModel,
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About me',
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Container(),
                    SizedBox(height: 4),
                    Text(
                      userModel.aboutMe,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(userModel.phoneNumber,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )))
            ],
          );
        },
      ),
    );
  }

  Widget buildFriendRequestButton({
    required AuthenticationProvider currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendRequestUids.isNotEmpty) {
      return _buildButton(
          'View friend request', Colors.purple, () {
        Navigator.pushNamed(context, Constants.friendRequestScreen);
      });
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildFriendsButton({
    required AuthenticationProvider currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendUids.isNotEmpty) {
      return _buildButton('View friends', Colors.black45, () {

        // Navigate to friends screen
        Navigator.pushNamed(context, Constants.friendScreen);
      });
    } else {
      if (currentUser.uid != userModel.uid) {
        //show cancel friend request if the friend request
        //else show send friend request

        String label = '';
        final containFriendUid =
            userModel.friendRequestUids.contains(currentUser.uid);

        if (containFriendUid) {
          label = 'Cancel friend request';
          return _buildButton(label, Colors.redAccent, () async {
            // Send friend request

            context
                .read<AuthenticationProvider>()
                .cancelFriendRequest(friendId: userModel.uid)
                .whenComplete(() {
              showSnackBar(context, 'friend request canceled');
            });
          });
        } else if (userModel.sentFriendRequestUids
            .contains(currentUser.uid)) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child:
                  _buildButton(
                      'Accept',
                      Colors.purple,
                          () async {
                        context
                            .read<AuthenticationProvider>()
                            .acceptOrDeclineFriendRequest(friendId: userModel.uid, accept: true)
                            .whenComplete(() {
                          showSnackBar(context, 'You are now friend with ${userModel.name}');
                        });
                      })
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildButton('Decline', Colors.red, () async {
                    context
                        .read<AuthenticationProvider>()
                        .acceptOrDeclineFriendRequest(friendId: userModel.uid, accept: false)
                        .whenComplete(() {
                      showSnackBar(context, 'You reject ${userModel.name} request');
                    });
                  }),
                ),
              ]);
        } else if (userModel.friendUids.contains(currentUser.uid)) {
          return Row(
            children: [
              Expanded(
                child: _buildButton(
                    'Chat', Colors.green, () async {
                      String emptyString = '';
                  Navigator.pushNamed(
                    context,
                    Constants.chatScreen,
                    arguments: {
                      Constants.contactId: userModel.uid,
                      Constants.contactName: userModel.name,
                     Constants.contactImage: userModel.image,
                      Constants.groupId : emptyString

                    }
                  );
                
                     
                }),
              ),


              Expanded(
                child: _buildButton(
                    'Unfriend', Colors.red, () async {

                  //create a dialog to confirm log out

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Comfirm Action'),
                      content: Text('Are you sure you want to Unfriend ${userModel.name}'),
                      actions: [
                        TextButton(
                          onPressed: () async {


                            context
                                .read<AuthenticationProvider>()
                                .unFriend(friendId: userModel.uid)
                                .whenComplete(() {
                              showSnackBar(context, 'You are no longer friend with ${userModel.name}');
                            });
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          );

        } else {
          label = 'send friend request';
          return _buildButton(label, Colors.blue, () async {
            context
                .read<AuthenticationProvider>()
                .sendFriendRequest(friendId: userModel.uid)
                .whenComplete(() {
              showSnackBar(context, 'Freind request sent');
            });
          });
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildButton(String text, Color color, VoidCallback action) {
    return AppButton(
      action: action,
      textColor: Colors.white,
      buttonBackground: color,
      buttonText: text,
      splashColor: color,
    );
  }

  void navigateToLoginScreen() {
    Navigator.pushNamedAndRemoveUntil(
        context, Constants.loginScreen, (route) => false);
  }
}
