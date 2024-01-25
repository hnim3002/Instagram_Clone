import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;

import '../providers/user_provider.dart';

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              backgroundColor: isDarkMode ? Colors.white : Colors.black
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              backgroundColor: isDarkMode ? Colors.white : Colors.black
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.add_box_outlined),
              backgroundColor: isDarkMode ? Colors.white : Colors.black
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border_outlined),
              backgroundColor: isDarkMode ? Colors.white : Colors.black
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.supervised_user_circle),
              backgroundColor: isDarkMode ? Colors.white : Colors.black
          ),
        ],
      ),
    );
  }
}
