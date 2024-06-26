import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


import 'package:instagram_clon/screens/user_screen/edit_user_screen.dart';
import 'package:instagram_clon/screens/user_follow_data_screen.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../Widgets/custom_gridview_img_widgets.dart';
import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';
import '../../resources/firestore_method.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserPostData() async {
    return FirestoreMethods().getUserPost(
        Provider.of<UserProvider>(context, listen: false).user!.uid!);
  }

  Future<List<Map<String, dynamic>>> getUserLikePost() async {
    return FirestoreMethods().getUserLikePost(
        Provider.of<UserProvider>(context, listen: false).user!.like!);
  }

  Future<List<Map<String, dynamic>>> getUserSavePost() async {
    return FirestoreMethods().getUserSavePost(
        Provider.of<UserProvider>(context, listen: false).user!.save!);
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 40,
                  height: 5, // Height of the divider
                  margin: const EdgeInsets.symmetric(
                      vertical: 10), // Adjust vertical spacing
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    color: Colors.grey[700], // Divider color
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Log out'),
                        onTap: () {
                          Navigator.pop(context);
                          signOut();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final model.User? user = Provider.of<UserProvider>(context).user;
    final String userName = user!.username!;
    final String userFullName = user.fullname!;
    final String userBio = user.bio!;
    final int numberOfPosts = user.post!.length;
    final int numberOfFollow = user.followers!.length;
    final int numberOfFollowing = user.following!.length;
    return Scaffold(
      body: SafeArea(
          child: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                  backgroundColor: Colors.white,
                  expandedHeight: 240,
                  title: Text(
                    userName,
                    style: const TextStyle(
                        letterSpacing: 0.5,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        highlightColor: Colors.transparent,
                        enableFeedback: false,
                        color: isDarkMode ? Colors.white : Colors.black,
                        iconSize: 30,
                        onPressed: () {
                          showBottomSheet();
                        },
                        icon: const Icon(
                          Symbols.menu_rounded,
                        )),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  CachedNetworkImageProvider(user.photoUrl!),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  UserDataColumn(
                                    number: numberOfPosts,
                                    text: 'posts',
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: UserFollowData(
                                                  intIndex: 0, userFollowers: user.followers!, userFollowing: user.following!, userName: user.username!,)));
                                    },
                                    child: UserDataColumn(
                                      number: numberOfFollow,
                                      text: 'followers',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: UserFollowData(
                                                  intIndex: 1, userFollowers: user.followers!, userFollowing: user.following!, userName: user.username!,)));
                                    },
                                    child: UserDataColumn(
                                      number: numberOfFollowing,
                                      text: 'following',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "    $userFullName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "    $userBio",
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  //Navigator.of(context, rootNavigator: true).pushNamed("/edit-user-screen");
                                  Navigator.of(context, rootNavigator: true)
                                      .push(PageTransition(
                                          type: PageTransitionType.bottomToTop,
                                          child: const EditProfile()));
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  minimumSize: const Size(60, 35),
                                  backgroundColor: const Color(0xFFEEEEEE),
                                  elevation: 0.1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adjust the border radius here
                                  ),
                                ),
                                child: const Text(
                                  "Edit profile",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )),
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  minimumSize: const Size(60, 35),
                                  backgroundColor: const Color(0xFFEEEEEE),
                                  elevation: 0.1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adjust the border radius here
                                  ),
                                ),
                                child: const Text(
                                  "Share profile",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  )),
              SliverPersistentHeader(
                delegate: MyDelegate(TabBar(
                  indicator: null,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: isDarkMode ? Colors.white : Colors.black,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.favorite_border_outlined)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.black,
                )),
                pinned: true,
              )
            ];
          },
          body: TabBarView(
            children: [
              CustomGridViewImg(
                getUserPostData: getUserPostData(),
              ),
              CustomGridViewImg(
                getUserPostData: getUserLikePost(),
              ),
              CustomGridViewImg(
                getUserPostData: getUserSavePost(),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class UserDataColumn extends StatelessWidget {
  final int number;
  final String text;
  const UserDataColumn({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          text,
          style: const TextStyle(letterSpacing: 0),
        )
      ],
    );
  }
}
