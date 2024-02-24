import 'package:flutter/material.dart';
import 'package:instagram_clon/screens/search_screen/sup_search_screen.dart';

import 'package:material_symbols_icons/symbols.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SubSearchScreen())); }, child: Text("search"),),
        ),
      ),
    );
  }
}
