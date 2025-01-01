import 'package:flutter/material.dart';

import '../utilities/assets_manager.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(200),
                clipBehavior: Clip.antiAlias,




                child: Image.asset(AssetsManager.userImage,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,

                ),

              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          const Text('Name: John Doe'),
          const Text('Age: 30'),
          const Text('Address: 123 Main St'),
        ],
      ),
    );
  }
}
