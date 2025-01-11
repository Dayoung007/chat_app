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
      appBar: AppBar(centerTitle: true, title: Text('Profile'), actions: [
        currentUser.uid == uid
            ? IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  //create a method for log out
                  //create a dialog to confirm log out

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await currentUser.logout().whenComplete(() {
                              // navigate to login screen

                              navigateToLoginScreen();
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
                },
              )
            : SizedBox()
      ]),
      body: StreamBuilder<DocumentSnapshot>(
        stream: context.read<AuthenticationProvider>().usersStream(userId: uid),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text("User not found");
          }
          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildFriendRequestButton(
                      currentUser: currentUser,
                      userModel: userModel,
                    ),
                  ),
                  Expanded(
                    child: buildFriendsButton(
                      currentUser: currentUser,
                      userModel: userModel,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
  return (currentUser.uid == userModel.uid && userModel.friendRequestUids.isNotEmpty)
      ? _buildButton('View friend request', Colors.purple, () {})
      : const SizedBox.shrink();
}

Widget buildFriendsButton({
  required AuthenticationProvider currentUser,
  required UserModel userModel,
}) {
  final isSameUser = currentUser.uid == userModel.uid;
  final hasFriends = userModel.friendUids.isNotEmpty;

  return _buildButton(
    isSameUser && hasFriends ? 'View friends' : 'Send friend request',
    Colors.blueAccent,
    isSameUser && hasFriends ? () {} : () {/* Send friend request */},
  );
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
  Navigator.pushNamedAndRemoveUntil(context, Constants.loginScreen, (route) => false);
}
}
