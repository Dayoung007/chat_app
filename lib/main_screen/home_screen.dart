import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_chat_app/main_screen/chats_list_screen.dart';
import 'package:new_chat_app/main_screen/group_screen.dart';
import 'package:new_chat_app/main_screen/people_screen.dart';
import 'package:new_chat_app/main_screen/setting_screens.dart';
import 'package:new_chat_app/utilities/assets_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = [
    ChatsListScreen(),
    GroupScreen(),
    PeopleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(AssetsManager.userImage),
            ),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: 'People',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
      ),
    );
  }
}
