import 'package:flutter/material.dart';
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
  Future<List<Map<String, dynamic>>> getPostData() async {
    return await FirestoreMethods().getUserPost(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found'));
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        combinedData: snapshot.data![index],
                        user: Provider.of<UserProvider>(context).user!,
                        index: index,
                      );
                    });
              })),
    );
  }
}
