import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/widget/friend_list.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() =>
      _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends request'),
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
          child: FriendList(
            viewType: FriendViewType.friendRequest,
          ),
        ),
      ]),
    );
  }
}
