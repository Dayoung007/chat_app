import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/authentication/landing_screen.dart';
import 'package:new_chat_app/authentication/login_screen.dart';
import 'package:new_chat_app/authentication/otp_screen.dart';
import 'package:new_chat_app/authentication/user_information_screen.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/main_screen/chat_screen.dart';
import 'package:new_chat_app/main_screen/friend_request_screen.dart';
import 'package:new_chat_app/main_screen/friends_screen.dart';
import 'package:new_chat_app/main_screen/profile_screen.dart';
import 'package:new_chat_app/main_screen/setting_screens.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import 'main_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Constants.landingScreen,
      routes: {

        Constants.loginScreen: (context) => const LoginScreen(),
        Constants.otpScreen: (context) => const OtpScreen(),
        Constants.userInformationScreen: (context) => const UserInformationScreen(),
        Constants.homeScreen: (context) => const HomeScreen(),
        Constants.landingScreen : (context) => const LandingScreen(),
        Constants.profileScreen : (context) => ProfileScreen(),
        Constants.settingScreen : (context) => SettingScreens(),
        Constants.friendRequestScreen : (context) => FriendRequestScreen(),
        Constants.friendScreen : (context) => FriendsScreen(),
        Constants.chatScreen : (context) => ChatScreen(),


      }

    );
  }
}
