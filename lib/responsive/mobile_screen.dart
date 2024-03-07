import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clon/screens/Home_screen.dart';
import 'package:instagram_clon/screens/select_img.dart';
import 'package:instagram_clon/screens/search_screen/search_screen.dart';
import 'package:instagram_clon/screens/user_screen/userprofile_screen.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/notification_screen.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final PageController _pageViewController = PageController(initialPage: 1);
  int pageViewIndex = 1;

  void closeBtnOnPressed() {
    _pageViewController.animateToPage(1,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CupertinoTabController _cupertinoTabController =
      CupertinoTabController();
  int _selectedIndex = 0;

  void navigationTapped(int index) {
    if (index == 0) {
      _selectedIndex = 0;
      _cupertinoTabController.index = 0;
    } else if (index == 1) {
      _selectedIndex = 1;
      _cupertinoTabController.index = 1;
    } else if (index == 2) {
      _cupertinoTabController.index = _selectedIndex;
      Navigator.pushNamed(context, "/post-screen");
    } else if (index == 3) {
      _selectedIndex = 2;
    } else if (index == 4) {
      _selectedIndex = 3;
    }
  }

  void onBackSearchPress() {
    _cupertinoTabController.index = 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return CupertinoTabScaffold(
        controller: _cupertinoTabController,
        tabBar: CupertinoTabBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Symbols.home_rounded),
              activeIcon: Icon(
                Symbols.home_rounded,
                fill: 1,
                weight: 500,
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Symbols.search_rounded),
              activeIcon: Icon(
                Symbols.search_rounded,
                weight: 700,
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Symbols.add_box_rounded),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Symbols.favorite),
              activeIcon: Icon(
                Symbols.favorite,
                fill: 1,
              ),
            ),
            BottomNavigationBarItem(
              icon: Provider.of<UserProvider>(context).user?.photoUrl == null
                  ? const Icon(Icons.person)
                  : CachedNetworkImage(
                      imageUrl:
                          Provider.of<UserProvider>(context, listen: false)
                              .user!
                              .photoUrl!,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 14,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) =>
                          Container(color: Colors.white60),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
              activeIcon:
                  Provider.of<UserProvider>(context).user?.photoUrl == null
                      ? const Icon(Icons.person)
                      : CircleAvatar(
                          radius: 16,
                          backgroundImage: CachedNetworkImageProvider(
                              Provider.of<UserProvider>(context, listen: false)
                                  .user!
                                  .photoUrl!),
                        ),
            ),
          ],
          height: 55,
          border: const Border(
            top: BorderSide(
              color: Color(0xffAEADB2),
              width: 0.3,
            ),
          ),
          inactiveColor: isDarkMode ? Colors.white : Colors.black,
          activeColor: isDarkMode ? Colors.white : Colors.black,
          backgroundColor: !isDarkMode ? Colors.white : Colors.black,
          onTap: (index) {
            setState(() {
              navigationTapped(index);
            });
          },
        ),
        tabBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                builder: (context) => const HomeScreen(),
              );
            case 1:
              return PopScope(
                canPop: false,
                onPopInvoked: (bool didPop) {
                  if (didPop) {
                    return;
                  }
                  onBackSearchPress();
                },
                child: CupertinoTabView(
                  builder: (context) => SearchScreen(),
                ),
              );
            case 4:
              return CupertinoTabView(
                builder: (context) => const UserProfileScreen(),
              );
            default:
              return CupertinoTabView(
                builder: (context) => Container(),
              );
          }
        });
  }
}
