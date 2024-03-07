import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clon/providers/user_provider.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../Widgets/post_card_widgets.dart';
import '../models/post.dart';
import '../models/user.dart' as model;
import '../providers/posts_provider.dart';
import '../providers/posts_state_provider.dart';
import '../utils/color_schemes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late StreamSubscription<QuerySnapshot> _postsSubscription;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _postsSubscription.cancel();
    super.dispose();
  }

  // void updatePostDataListener() {
  //   _postsSubscription = FirebaseFirestore.instance
  //       .collection(kKeyCollectionPosts)
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) async {
  //     print(snapshot.size);
  //
  //     for (var updatedPost in snapshot.docs) {
  //       String updatedPostId = updatedPost.id;
  //       Map<String, dynamic> updatedPostData =
  //           updatedPost.data() as Map<String, dynamic>;
  //       int index = combinedData
  //           .indexWhere((item) => item['post'][kKeyPostId] == updatedPostId);
  //       if (index != -1) {
  //         combinedData[index]['post'] = updatedPostData;
  //       }
  //     }
  //   });
  // }

  Future<void> getPostData() async {
    await Provider.of<PostsProvider>(context, listen: false).initPostData();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final model.User? user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      extendBody: true,
      key: UniqueKey(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return getPostData();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0 ,
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
                    return PostCard(
                      user: user!,
                      index: index,
                    );
                  },
                  childCount: Provider.of<PostsStateProvider>(context).postDataSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
