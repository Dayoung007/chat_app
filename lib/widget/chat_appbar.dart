import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/models/user_model.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:provider/provider.dart';

class ChatAppbar extends StatefulWidget {
  const ChatAppbar({super.key, required this.contactId});

  @override
  State<ChatAppbar> createState() => _ChatAppbarState();
  final String contactId;
}

class _ChatAppbarState extends State<ChatAppbar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: context
          .read<AuthenticationProvider>()
          .usersStream(userId: widget.contactId),
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

        return
        Row(
            children: [
              userImageWidget(
                  radius: 20,
                  onTap: () {},
                  imageUrl: userModel.image),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    userModel.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "online",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

        );
      },
    );
  }
}
