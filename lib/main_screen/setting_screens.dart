
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      body: Center(
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
    );
  }
}
