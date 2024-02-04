import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clon/screens/post_screen/select_img.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;

import '../providers/user_provider.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final PageController _pageViewController = PageController(initialPage: 1);
  final PageController _navigationController = PageController();
  int _selectedIndex = 0;
  int _viewPageIndex = 1;

  void navigationTapped(int index) {
    if(index == 0) {
      _navigationController.jumpToPage(index);
    } else if (index == 1) {
      _navigationController.jumpToPage(index);
    } else if (index == 2) {
      _pageViewController.animateToPage(0, duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    } else if (index == 3) {
      _navigationController.jumpToPage(index--);
    } else if (index == 4) {
      _navigationController.jumpToPage(index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageViewController,
          children: <Widget>[
            PostScreen(
              closeBtnOnPressed: () {
                _pageViewController.animateToPage(1, duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
            ),
            Center(
              child: Text('Home_Screen'),
            ),
            Center(
              child: Text('Chat_Screen'),
            ),
          ],
          onPageChanged: (index) {
            setState(() {
              _viewPageIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar:_viewPageIndex == 1 ? BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/ic_search_outline.svg",
              height: 23,
              width: 23,
            ),
            label: '',
            activeIcon: SvgPicture.asset(
              "assets/images/ic_search_fill.svg",
              height: 23,
              width: 23,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            label: '',
            activeIcon: Icon(Icons.favorite)),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: '',
          ),
        ],
        backgroundColor: !isDarkMode ? Colors.white : Colors.black,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            navigationTapped(index);
          });
        },
      ) : null
    );
  }
}
