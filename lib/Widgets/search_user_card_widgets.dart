import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/utils/const.dart';

import '../models/user.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  const UserCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: userData[kKeyUserPhoto],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 20,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      title: Text(userData[kKeyUserName]),
      subtitle: Text(userData[kKeyFullName]),
    );
  }
}
