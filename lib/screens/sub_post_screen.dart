import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/providers/posts_state_provider.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:provider/provider.dart';

import '../Widgets/post_card_widgets.dart';
import '../providers/posts_provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_schemes.dart';

class PostSearchScreen extends StatefulWidget {
  final String postId;
  final String uid;
  const PostSearchScreen({super.key, required this.postId, required this.uid});

  @override
  State<PostSearchScreen> createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends State<PostSearchScreen> {
  bool isFollowing = false;
  bool isVisible = true;

  void checkUserFollowing() {
    isVisible = !Provider.of<UserProvider>(context, listen: false).user!.following!.contains(widget.uid);
  }

  Future<int> getPostData() async {
    return Provider.of<PostsProvider>(context, listen: false).getAPost(widget.postId);
  }

  Future<void> updateUserFollowing() async {
    await FirestoreMethods().updateUserFollowing(Provider.of<UserProvider>(context, listen: false).user!.uid!, isFollowing, widget.uid);
    updateUserData();
  }

  Future<void> updateUserData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  void initState() {
    getPostData();
    checkUserFollowing();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onFollowPress() {
    setState(() {
      isFollowing = true;
    });
    updateUserFollowing();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Posts",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: InkWell(

              onTap: () {

              },
              child: Text(
                !isFollowing ? "Follow" : "Following",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: blueBtnColor,
                  letterSpacing: 1
                ),
              )
            ),
          ),
          const SizedBox(width: 40,)
        ],
      ),
      body: SafeArea(
          child: FutureBuilder(
              future: getPostData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return PostCard(
                  user: Provider.of<UserProvider>(context, listen: false).user!,
                  index: 0,
                  isSub: true,
                );
              }),
      ),
    );
  }
}
