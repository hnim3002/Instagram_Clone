import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:page_transition/page_transition.dart';

import '../models/user.dart';
import '../screens/search_screen/user_profile_info_screen.dart';

class UserCard extends StatelessWidget {
  final bool isReverse;
  final Map<String, dynamic> userData;
  const UserCard({super.key, required this.userData, this.isReverse = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: userData[kKeyUserPhoto],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 27,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      title: Text(!isReverse ? userData[kKeyUserName] : userData[kKeyFullName]),
      subtitle: Text(
        !isReverse ? userData[kKeyFullName] : userData[kKeyUserName],
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        if(isReverse) {

        } else {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: UserProfileInfoScreen(
                    uid: userData[kKeyUsersId],
                  )));
        }
      },
    );
  }
}
