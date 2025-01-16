
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/constant.dart';
import 'package:new_chat_app/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class SettingScreens extends StatefulWidget {
  const SettingScreens({super.key});

  @override
  State<SettingScreens> createState() => _SettingScreensState();
}

class _SettingScreensState extends State<SettingScreens> {

  bool isDarkMode = false;

  //get save theme mode
  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final currentUser = context.read<AuthenticationProvider>();

    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Settings'), actions: [
        currentUser.uid == uid
            ? IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            //create a method for log out
            //create a dialog to confirm log out

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Logout'),
                content: Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await currentUser.logout().whenComplete(() {
                        // navigate to login screen

                        navigateToLoginScreen();
                      });
                    },
                    child: Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('No'),
                  ),
                ],
              ),
            );
          },
        )
            : SizedBox()
      ]),
      body: Container(
        color:
        isDarkMode? Colors.black : Colors.white,


        child: Center(
          child: Card(
            child: SwitchListTile(
                title: Text('Change Theme'),
                secondary: Container(
                    child: Container(
                      decoration: BoxDecoration (
                        borderRadius: BorderRadius.circular(10.0),
                        color: isDarkMode? Colors.black38 : Colors.white38,
                      ),
                      child: Icon(
                          isDarkMode ? Icons.nightlight_round : Icons.nightlight_round,
                          color:
                          isDarkMode ? Colors.black : Colors.white),
                    )),
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                  if (value) {
                    AdaptiveTheme.of(context).setDark();
                  } else {
                    AdaptiveTheme.of(context).setLight();
                  }
                }),
          ),
        ),
      ),
    );
  }

  void navigateToLoginScreen() {
    Navigator.pushNamedAndRemoveUntil(context, Constants.loginScreen, (route) => false);
  }
}
