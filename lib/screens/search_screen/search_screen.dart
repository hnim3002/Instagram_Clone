import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/search_user_card_widgets.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/screens/search_screen/post_search_screen.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

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
        child:  FutureBuilder(
            future: getUserPostData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('No users found'));
              }
              return GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
                children: snapshot.data!.map((map) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PostSearchScreen(uid: map[kKeyUsersId])));
                    },
                    child: CachedNetworkImage(
                      imageUrl: map[kKeyPostPhoto],
                      imageBuilder: (context, imageProvider) => FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: MemoryImage(kTransparentImage),
                        image: imageProvider,
                      ),
                      placeholder: (context, url) => Container(color: Colors.white60),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  );
                }).toList(),
              );
            }),
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
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user =
                snapshot.data!.docs[index] as Map<String, dynamic>;
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
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var userData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return UserCard(userData: userData);
          },
        );
      },
    );
  }
}
