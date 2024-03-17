import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:page_transition/page_transition.dart';

import '../models/user.dart';
import '../screens/search_screen/user_profile_info_screen.dart';

class ChatUserCard extends StatelessWidget {

  final Map<String, dynamic> chatRoomData;
  final Map<String, dynamic> userData;
  const ChatUserCard({super.key, required this.userData, required this.chatRoomData, });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CachedNetworkImage(
        imageUrl: userData[kKeyUserPhoto],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 27,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      title: Text(userData[kKeyFullName],
        style: TextStyle(
           letterSpacing: 0,
           fontWeight: chatRoomData[kKeyIsSeen] ? FontWeight.normal : FontWeight.bold,
        )
      ),
      subtitle: Text(
        chatRoomData[kKeyLastMessage],
        style: TextStyle(
          color: chatRoomData[kKeyIsSeen] ? Colors.grey : Colors.black,
          fontWeight: chatRoomData[kKeyIsSeen] ? FontWeight.normal : FontWeight.bold,
          letterSpacing: 0.5
        ),
      ),
      onTap: () {


      },
    );
  }
}
