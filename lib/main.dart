import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/authentication/login_screen.dart';
import 'package:new_chat_app/authentication/otp_screen.dart';
import 'package:new_chat_app/authentication/user_information_screen.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserInformationScreen(),
    );
  }
}
