import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/utils/const.dart';

import '../screens/chat_screen/messaging_screen.dart';

class ChatUserCard extends StatelessWidget {
  final Map<String, dynamic> chatRoomData;
  final Map<String, dynamic> userData;
  const ChatUserCard({
    super.key,
    required this.userData,
    required this.chatRoomData,
  });

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
      title: chatRoomData[kKeySenderId] == userData[kKeyUsersId]
          ? Text(userData[kKeyFullName],
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: chatRoomData[kKeyIsSeen]
                    ? FontWeight.normal
                    : FontWeight.bold,
              ))
          : Text(userData[kKeyFullName],
              style: const TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.normal,
              )),
      subtitle: chatRoomData[kKeySenderId] == userData[kKeyUsersId]
          ? Text(
              chatRoomData[kKeyLastMessage],
              style: TextStyle(
                  color: chatRoomData[kKeyIsSeen] ? Colors.grey : Colors.black,
                  fontWeight: chatRoomData[kKeyIsSeen]
                      ? FontWeight.normal
                      : FontWeight.bold,
                  letterSpacing: 0.5),
            )
          : Text(
              "You: ${chatRoomData[kKeyLastMessage]}",
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.5),
            ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagingScreen(
                userData: userData, chatRoomId: chatRoomData[kKeyChatRoomId]),
          ),
        );
      },
    );
  }
}
