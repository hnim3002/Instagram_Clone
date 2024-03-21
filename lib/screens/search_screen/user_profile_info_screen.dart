import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/screens/chat_screen/messaging_screen.dart';
import 'package:instagram_clon/screens/user_follow_data_screen.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../Widgets/custom_gridview_img_widgets.dart';
import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';
import '../../resources/firestore_method.dart';
import '../../utils/color_schemes.dart';

class UserProfileInfoScreen extends StatefulWidget {
  final String uid;
  const UserProfileInfoScreen({super.key, required this.uid});

  @override
  State<UserProfileInfoScreen> createState() => _UserProfileInfoScreenState();
}

class _UserProfileInfoScreenState extends State<UserProfileInfoScreen> {
  ValueNotifier<Map<String, dynamic>?> userData = ValueNotifier<Map<String, dynamic>?>(null);
  String chatRoomId = '';

  String? userId;
  String? userName;
  String? userFullName;
  String? userBio;
  String? userPhoto;
  int numberOfPosts = 0;
  int numberOfFollow = 0;
  int numberOfFollowing = 0;
  bool? isFollowing;


  Future<void> getUserData() async {
    chatRoomId = await FirestoreMethods().getChatRoomId(FirebaseAuth.instance.currentUser!.uid ,widget.uid);
    userData.value = await FirestoreMethods().getAUser(widget.uid);
    userId = userData.value![kKeyUsersId];
    userName = userData.value![kKeyUserName];
    userFullName = userData.value![kKeyFullName];
    userBio = userData.value![kKeyUserBio];
    userPhoto = userData.value![kKeyUserPhoto];
    numberOfPosts = userData.value![kKeyUserPost].length;
    numberOfFollow = userData.value![kKeyUserFollowers].length;
    numberOfFollowing = userData.value![kKeyUserFollowing].length;
    if (!mounted) return;
    isFollowing = Provider.of<UserProvider>(context, listen: false).user!.following!.contains(userId);
  }

  Future<List<Map<String, dynamic>>> getUserPostData(String uid) async {
    return FirestoreMethods().getUserPost(uid);
  }

  Future<void> updateUserFollowing(String uid, bool isFollowing, String followingId) async {
    await FirestoreMethods().updateUserFollowing(uid, isFollowing, followingId);
    updateUserData();
  }

  Future<void> updateUserData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final model.User? user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 1,
          child: ValueListenableBuilder(
            valueListenable: userData,
            builder: (BuildContext context, value, Widget? child) {
              if(value == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                        backgroundColor: Colors.white,
                        expandedHeight: 240,
                        title: Text(
                          userName!,
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
                              onPressed: () {},
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                    CachedNetworkImageProvider(userPhoto!),
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
                                          number: numberOfPosts!,
                                          text: 'posts',
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const UserFollowData(
                                                        intIndex: 0)));
                                          },
                                          child: UserDataColumn(
                                            number: numberOfFollow!,
                                            text: 'followers',
                                          ),
                                        ),
                                        UserDataColumn(
                                          number: numberOfFollowing!,
                                          text: 'following',
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "    $userBio",
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isFollowing = !isFollowing!;
                                          if(isFollowing!) {
                                            numberOfFollow++;

                                          } else {
                                            numberOfFollow--;
                                          }
                                        });
                                        updateUserFollowing(user!.uid!, isFollowing!, userId!);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 53),
                                        minimumSize: const Size(60, 33),
                                        backgroundColor: isFollowing!
                                            ? const Color(0xFFEEEEEE)
                                            : blueBtnColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Adjust the border radius here
                                        ),
                                      ),
                                      child: Text(
                                        isFollowing! ? "Following" : "Follow",
                                        style: TextStyle(
                                            color: isFollowing! ? Colors.black : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context, rootNavigator: true).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MessagingScreen(userData: userData.value!, chatRoomId: chatRoomId,)));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 53),
                                        minimumSize: const Size(60, 33),
                                        backgroundColor:
                                        const Color(0xFFEEEEEE),
                                        elevation: 0.1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0),
                                        ),
                                      ),
                                      child: const Text(
                                        "Message",
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
                        indicatorColor:
                        isDarkMode ? Colors.white : Colors.black,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on)),
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
                      getUserPostData: getUserPostData(userId!),
                    ),
                  ],
                ),
              );
            },
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
