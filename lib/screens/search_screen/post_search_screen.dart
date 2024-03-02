import 'package:flutter/material.dart';
import 'package:instagram_clon/providers/posts_state_provider.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:provider/provider.dart';

import '../../Widgets/post_card_widgets.dart';
import '../../providers/posts_provider.dart';
import '../../providers/user_provider.dart';

class PostSearchScreen extends StatefulWidget {
  final String uid;
  const PostSearchScreen({super.key, required this.uid});

  @override
  State<PostSearchScreen> createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends State<PostSearchScreen> {



  Future<void> getPostData() async {
    Provider.of<PostsStateProvider>(context, listen: false).getSubPostDataSize(await Provider.of<PostsProvider>(context, listen: false).initSubPostData(widget.uid));
  }

  @override
  void initState() {
    getPostData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: SafeArea(
          child: ListView.builder(
              itemCount:  Provider.of<PostsStateProvider>(context).subPostDataSize,
              itemBuilder: (context, index) {
                return PostCard(
                  user: Provider.of<UserProvider>(context).user!,
                  index: index,
                  isSub: true,
                );
              }),
      ),
    );
  }
}
