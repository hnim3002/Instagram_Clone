
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clon/screens/post_screen/select_img.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
      bottomNavigationBar: _viewPageIndex == 1 ? Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xffAEADB2),
              width: 0.3,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Symbols.home_rounded),
              label: '',
              activeIcon: Icon(Symbols.home_rounded, fill: 1, weight: 500,),
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.search_rounded),
              label: '',
              activeIcon: Icon(Symbols.search_rounded, weight: 700,),
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.add_box),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Symbols.favorite),
              label: '',
              activeIcon: Icon(Symbols.favorite, fill: 1,),),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: '',
            ),
          ],
          backgroundColor: !isDarkMode ? Colors.white : Colors.black,
          unselectedItemColor: isDarkMode ? Colors.white : Colors.black,
          selectedItemColor: isDarkMode ? Colors.white : Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              navigationTapped(index);
            });
          },
        ) ,
      ) : null,
    );
  }
}
