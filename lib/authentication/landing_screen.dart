import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../utilities/assets_manager.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  Future<void> checkAuthentication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.checkAuthenticationState();
    navigate(isAuthenticated: isAuthenticated);
  }

  navigate({required bool isAuthenticated}) {
    isAuthenticated
        ? Navigator.pushReplacementNamed(context, Constants.homeScreen)
        : Navigator.pushReplacementNamed(context, Constants.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: Lottie.asset(AssetsManager.chatbubble),
          ),
          Padding(
            padding: const EdgeInsets.all(36.0),
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey,
              color: Colors.blue,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
        ],
      )),
    );
  }
}
