import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;

import '../providers/user_provider.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final PageController _pageViewController = PageController();
  final PageController _navigationController = PageController();
  int _selectedIndex = 0;
  int _viewPageIndex = 0;

  void navigationTapped(int index) {
    _navigationController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: _pageViewController,
          children: <Widget>[
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _navigationController,
              children: const [
                Center(
                  child: Text('1'),
                ),
                Center(
                  child: Text('2'),
                ),
                Center(
                  child: Text('3'),
                ),
                Center(
                  child: Text('4'),
                ),
                Center(
                  child: Text('5'),
                ),
              ],

            ),
            const Center(
              child: Text('Second Page'),
            ),
          ],
          onPageChanged: (index) {
            setState(() {
              _viewPageIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar:_viewPageIndex == 0 ? BottomNavigationBar(
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
