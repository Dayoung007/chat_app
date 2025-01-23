import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/widget/bottom_chat_field.dart';
import 'package:new_chat_app/widget/chat_appbar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // get arguments from the previous screen
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, String>;
    final contactId = args[Constants.contactId];
    final contactName = args[Constants.contactName];
    final contactImage = args[Constants.image];

    final groupId = args[Constants.groupId];
    //
    final isGroupChat = groupId!.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: ChatAppbar(
          contactId: contactId!,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Message from $contactName'),
                );
              },
            ),
          ),
          BottomChatField(
            contactId: contactId,
            contactName: contactName,
            contactImage: contactImage,
            groupId: null,
          )
        ],
      ),
    );
  }
}
