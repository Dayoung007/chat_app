import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.contactId,
    required this.groupId,
    required this.contactName,
    required this.contactImage,
  });

  final dynamic contactId;
  final dynamic groupId;
  final dynamic contactName;
  final dynamic contactImage;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {

  TextEditingController messageController = TextEditingController();


  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              color: Theme.of(context).hoverColor,

            ),
            child: TextFormField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 10),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),

                labelText: 'Message...',
                labelStyle: const TextStyle(fontSize: 16),
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attachment),
                ),
                  suffixIcon:  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child:  Icon(Icons.send,
                      color: Theme.of(context).cardColor,

                    ),
                    ),
                  ),
              ),
            ),
          ),


      ],
    );
  }
}
