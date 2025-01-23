import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:new_chat_app/widget/friend_list.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: Column(children: [
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Search',
            onChanged: (query) {
              // Handle search query changes
            },
          ),
        ),
        Expanded(
          child: FriendList(viewType:FriendViewType.friends,),
        ),
      ]),
    );
  }
}
