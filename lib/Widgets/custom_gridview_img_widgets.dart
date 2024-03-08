import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../screens/sub_post_screen.dart';
import '../utils/const.dart';


class CustomGridViewImg extends StatefulWidget {
  final Future<dynamic> getUserPostData;

  const CustomGridViewImg({super.key, required this.getUserPostData});

  @override
  State<CustomGridViewImg> createState() => _CustomGridViewImgState();
}

class _CustomGridViewImgState extends State<CustomGridViewImg> {

  late Future<dynamic> yourFuture;

  @override
  void initState() {
    super.initState();
    yourFuture = widget.getUserPostData; // Replace this with your actual future
  }
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: yourFuture,
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
                'No posts found',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              )
            );
          }
          return GridView.count(
            padding: const EdgeInsets.all(1),
            crossAxisCount: 3,
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            children:  (snapshot.data as List<dynamic>).map<Widget>((map){
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PostSearchScreen(uid: map[kKeyUsersId], postId: map[kKeyPostId],)));
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
        });
  }
}