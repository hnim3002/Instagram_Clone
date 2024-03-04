import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/search_user_card_widgets.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/screens/sub_post_screen.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../Widgets/custom_gridview_img_widgets.dart';
import '../../utils/const.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  Future<List<Map<String, dynamic>>> getUserPostData() async {
    List<String> users = [];
    users = await FirestoreMethods().getUsersId(
        Provider.of<UserProvider>(context, listen: false).user!.following!, Provider.of<UserProvider>(context, listen: false).user!.uid! );
    return FirestoreMethods().getPostUnique(users);
  }

  Future<void> refreshData() async {
    await getUserPostData();
    setState(() {});
  }

  @override
  void initState() {
    getUserPostData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showSearch(context: context, delegate: CustomSearchDelegate());
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                const Icon(Symbols.search_rounded),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Search",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child:  RefreshIndicator(
          onRefresh: () {
            return refreshData();
          },
          child: CustomGridViewImg(getUserPostData: getUserPostData(),),
        ),
      ),
    );
  }
}



class CustomSearchDelegate extends SearchDelegate{
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close_rounded))
    ];

  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));

  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(kKeyCollectionUsers)
          .orderBy(kKeyUserName)
          .where(kKeyUserName, isGreaterThanOrEqualTo: query)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        List<Map<String, dynamic>> updatedCombinedData = [];
        for (var userDoc in snapshot.data!.docs) {
          String userId = userDoc.get(kKeyUsersId);
          if (userId != Provider.of<UserProvider>(context).user!.uid) {
            updatedCombinedData.add(userDoc.data() as Map<String, dynamic>);
          }
        }
        return ListView.builder(
          itemCount: updatedCombinedData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = updatedCombinedData[index];
            return UserCard(userData: user);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(kKeyCollectionUsers)
          .orderBy(kKeyUserName)
          .where(kKeyUserName, isGreaterThanOrEqualTo: query)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        List<Map<String, dynamic>> updatedCombinedData = [];
        for (var userDoc in snapshot.data!.docs) {
          String userId = userDoc.get(kKeyUsersId);
          if (userId != Provider.of<UserProvider>(context).user!.uid) {
            updatedCombinedData.add(userDoc.data() as Map<String, dynamic>);
          }
        }
        return ListView.builder(
          itemCount: updatedCombinedData.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = updatedCombinedData[index];
            return UserCard(userData: user);
          },
        );
      },
    );
  }
}
