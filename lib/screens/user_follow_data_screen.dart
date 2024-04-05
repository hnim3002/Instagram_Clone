import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/screens/search_screen/user_profile_info_screen.dart';
import 'package:instagram_clon/utils/color_schemes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../resources/firestore_method.dart';
import '../utils/const.dart';

class UserFollowData extends StatefulWidget {
  final int intIndex;
  final List<dynamic> userFollowers;
  final List<dynamic> userFollowing;
  final String userName;
  const UserFollowData(
      {super.key,
      required this.intIndex,
      required this.userFollowers,
      required this.userFollowing,
      required this.userName});

  @override
  State<UserFollowData> createState() => _UserFollowDataState();
}

class _UserFollowDataState extends State<UserFollowData> {
  Future<List<Map<String, dynamic>>> getFollowersData() async {
    return FirestoreMethods().getUserFollow(widget.userFollowers);
  }

  Future<List<Map<String, dynamic>>> getFollowingData() async {
    return FirestoreMethods().getUserFollow(widget.userFollowing);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final int userFollowers = widget.userFollowers.length;
    final int userFollowing = widget.userFollowing.length;
    return DefaultTabController(
      initialIndex: widget.intIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.userName,
            style: const TextStyle(
                letterSpacing: 0.5, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicator: null,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: isDarkMode ? Colors.white : Colors.black,
            tabs: [
              Tab(icon: Text("$userFollowers followers")),
              Tab(icon: Text("$userFollowing following")),
            ],
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black,
          ),
        ),
        body: SafeArea(
            child: TabBarView(
          children: [
            UserFollowDataScreen(
              isFollowers: true,
              data: getFollowersData(),
            ),
            UserFollowDataScreen(
              isFollowers: false,
              data: getFollowingData(),
            ),
          ],
        )),
      ),
    );
  }
}

class UserFollowDataScreen extends StatefulWidget {
  final bool isFollowers;
  final Future<dynamic> data;
  const UserFollowDataScreen(
      {super.key, required this.isFollowers, required this.data});

  @override
  State<UserFollowDataScreen> createState() => _UserFollowDataScreenState();
}

class _UserFollowDataScreenState extends State<UserFollowDataScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No User Found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ));
          }
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return UserListTile(
                  userData: snapshot.data[index],
                  isFollowers: widget.isFollowers,
                );
              });
        });
  }
}

class UserListTile extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isFollowers;
  const UserListTile(
      {super.key, required this.userData, required this.isFollowers});

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  bool isBtnActive = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateUserFollowers(bool isFollowing) async {
    await FirestoreMethods().updateUserFollowers(
        Provider.of<UserProvider>(context, listen: false).user!.uid!,
        isFollowing,
        widget.userData[kKeyUsersId]);
    updateUserData();
  }

  Future<void> updateUserFollowing(bool isFollowing) async {
    await FirestoreMethods().updateUserFollowing(
        Provider.of<UserProvider>(context, listen: false).user!.uid!,
        isFollowing,
        widget.userData[kKeyUsersId]);
    updateUserData();
  }

  Future<void> updateUserData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: widget.userData[kKeyUserPhoto],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 20,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: UserProfileInfoScreen(
                  uid: widget.userData[kKeyUsersId],
                )));
      },
      title: Text(widget.userData[kKeyUserName]),
      subtitle: Text(widget.userData[kKeyFullName]),
      trailing: !widget.isFollowers
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  isBtnActive = !isBtnActive;
                });
                if (isBtnActive) {
                  updateUserFollowing(true);
                } else {
                  updateUserFollowing(false);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                minimumSize: const Size(50, 35),
                backgroundColor:
                    isBtnActive ? const Color(0xFFEEEEEE) : blueBtnColor,
                elevation: 0.1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Adjust the border radius here
                ),
              ),
              child: Text(
                isBtnActive ? "Following" : "Follow",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isBtnActive ? Colors.black : Colors.white),
              ))
          : ElevatedButton(
              onPressed: () {
                setState(() {
                  isBtnActive = !isBtnActive;
                });
                if (isBtnActive) {
                  updateUserFollowers(true);
                } else {
                  updateUserFollowers(false);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                minimumSize: const Size(60, 35),
                backgroundColor:
                    isBtnActive ? const Color(0xFFEEEEEE) : blueBtnColor,
                elevation: 0.1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Adjust the border radius here
                ),
              ),
              child: Text(
                isBtnActive ? "Remove" : "Undo",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isBtnActive ? Colors.black : Colors.white),
              ),
            ),
    );
  }
}
