import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../Widgets/post_card_widgets.dart';
import '../models/post.dart';
import '../models/user.dart' as model;
import '../providers/posts_provider.dart';
import '../utils/color_schemes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int i = 0;
  late StreamSubscription<QuerySnapshot> _postsSubscription;
  List<Map<String, dynamic>> combinedData = [];
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    getPostsData();
    updatePostDataListener();
    super.initState();
  }

  @override
  void dispose() {
    _postsSubscription.cancel();
    super.dispose();
  }

  void updatePostDataListener() {
    _postsSubscription = FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
          print(snapshot.size);

      for (var updatedPost in snapshot.docs) {

        String updatedPostId = updatedPost.id;
        Map<String, dynamic> updatedPostData = updatedPost.data() as Map<String, dynamic>;
        int index = combinedData.indexWhere((item) => item['post'][kKeyPostId] == updatedPostId);
        if (index != -1) {
          combinedData[index]['post'] = updatedPostData;
        }
      }
    });
  }


  Future<void> getPostData() async {
    await Provider.of<PostsProvider>(context, listen: false).refreshPostData();
  }


  Future<void> getPostsData() async {
    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .orderBy(kKeyTimestamp, descending: true)
        .get();

    List<String> userIds =
    postsSnapshot.docs.map((doc) => doc[kKeyUsersId] as String).toList();

    // Perform a query to fetch user data based on userIds
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionUsers)
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    // Create a map to store user data
    Map<String, Map<String, dynamic>> userDataMap = {};
    for (var doc in usersSnapshot.docs) {
      userDataMap[doc.id] = doc.data() as Map<String, dynamic>;
    }

    List<Map<String, dynamic>> updatedCombinedData = [];
    for (var postDoc in postsSnapshot.docs) {
      CollectionReference commentsRef = FirebaseFirestore.instance
          .collection(kKeyCollectionPosts)
          .doc(postDoc.id)
          .collection(kKeySubCollectionComment);

      int numberOfComments = (await commentsRef.get()).size;

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      String? userId = postData[kKeyUsersId] as String?;
      Map<String, dynamic> userData = userDataMap[userId] ?? {};
      updatedCombinedData.add(
          {'post': postData, 'user': userData, 'comment': numberOfComments});
    }

    if (!context.mounted) return;
    setState(() {
      combinedData = updatedCombinedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final model.User? user = Provider.of<UserProvider>(context).user;
    print(Provider.of<PostsProvider>(context, listen: false).listOfLike);
    print(Provider.of<PostsProvider>(context, listen: false).numberOfComment);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: getPostData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDarkMode ? Colors.black : primaryColor,
              title: SvgPicture.asset(
                height: 30,
                "assets/images/ic_instagram.svg",
                colorFilter: ColorFilter.mode(
                    isDarkMode ? primaryColor : Colors.black, BlendMode.srcIn),
              ),
              actions: [
                IconButton(
                    visualDensity: VisualDensity.compact,
                    highlightColor: Colors.transparent,
                    enableFeedback: false,
                    color: isDarkMode ? Colors.white : Colors.black,
                    iconSize: 25,
                    onPressed: () {},
                    icon: const Icon(
                      Symbols.chat_rounded,
                      weight: 500,
                    )),
              ],
              floating: true,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  //print(Provider.of<PostsProvider>(context, listen: false).postData?.length);
                  return PostCard(
                      combinedData: combinedData[index], user: user!, index: index,);
                },
                childCount:combinedData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
