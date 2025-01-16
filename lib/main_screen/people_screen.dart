import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:new_chat_app/utilities/global_method.dart';
import 'package:provider/provider.dart';

import '../constant.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();





  @override
  Widget build(BuildContext context) {

    final currentUser = context.read<AuthenticationProvider>().getUserModel!.uid;

    return Scaffold(
      body: Column(
        children: [
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
            child: StreamBuilder<QuerySnapshot>(
              stream: context.read<AuthenticationProvider>().getAllUsersStream(userId: currentUser,



              ),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found',
                  style: TextStyle(fontSize: 18)));
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return ListTile(
                      leading: userImageWidget(
                          radius: 20, onTap: () {


                      }, imageUrl: data['image']),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Constants.profileScreen,
                          arguments: document.id,

                        );
                      },
                      trailing: Icon(Icons.message),
                      title: Text(toTitleCase(data[Constants.name]),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )),
                      subtitle: Text(data[Constants.aboutMe],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
