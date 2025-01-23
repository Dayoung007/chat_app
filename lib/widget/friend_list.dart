import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:new_chat_app/widget/app_button.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class FriendList extends StatelessWidget {
  FriendList({super.key, required this.viewType});

  final FriendViewType viewType;

  @override
  Widget build(BuildContext context) {
    final uid =
        context.read<AuthenticationProvider>().getUserModel!.uid;
    final auth = context.read<AuthenticationProvider>();

    return FutureBuilder(
        future: viewType == FriendViewType.friends
            ? auth.getFriendsList(uid)
            : auth.getFriendRequestList(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                  child: Text(viewType == FriendViewType.friends
                      ? "No friends found"
                      : "No friend Request"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserModel friend = snapshot.data![index];

                return ListTile(
                  isThreeLine: viewType == FriendViewType.friends
                      ? false
                      : true,
                  dense: viewType == FriendViewType.friends
                      ? false
                      : true,
                  leading: userImageWidget(
                      radius: 20,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Constants.profileScreen,
                          arguments: auth.getUserModel!.uid,
                        );
                      },
                      imageUrl: friend.image),
                  trailing: viewType == FriendViewType.friends
                      ? GestureDetector(
                    onTap: () async {
                      String emptyString = '';
                      Navigator.pushNamed(
                          context,
                          Constants.chatScreen,
                          arguments: {
                            Constants.contactId: friend.uid,
                            Constants.contactName: friend.name,
                            Constants.contactImage: friend.image,
                            Constants.groupId : emptyString

                          }
                      );
                      },

                      child: Icon(Icons.message))
                      : SizedBox.shrink(),
                  title: Text(toTitleCase(friend.name),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        friend.aboutMe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      viewType == FriendViewType.friends ? SizedBox.shrink() :
                      Row(
                        children: [
                          SizedBox(width: 8),
                          Expanded(
                              child: _buildButton(
                                  text: 'Accept',
                                  color: Colors.green,
                                  action: () {})),
                          SizedBox(width: 8),
                          Expanded(
                              child: _buildButton(
                                  text: 'Reject',
                                  color: Colors.red,
                                  action: () {})),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }

          return Center(child: Text("Unexpected state"));
        });
  }

  Widget _buildButton(
      {required String text,
      required Color color,
      required VoidCallback action}) {
    return AppButton(
      action: action,
      textColor: Colors.white,
      buttonBackground: color,
      buttonText: text,
      splashColor: color,
    );
  }
}
