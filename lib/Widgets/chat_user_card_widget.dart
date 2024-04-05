import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String calculateDate(Timestamp timestamp) {
    DateTime timesNow = DateTime.now();
    DateTime dateTime = timestamp.toDate();

    // Calculate the difference between the two timestamps
    Duration difference = timesNow.difference(dateTime);

    // Calculate the difference in hours
    int hoursDifference = difference.inHours;

    if (hoursDifference >= 24) {
      int daysDifference = hoursDifference ~/ 24;
      if (daysDifference >= 7) {
        int weeksDifference = daysDifference ~/ 7;
        return "${weeksDifference}w";
      } else {
        return "${daysDifference}d";
      }
    } else if (hoursDifference >= 1) {
      return "${hoursDifference}h";
    } else {
      int minutesDifference = difference.inMinutes;
      if (minutesDifference < 1) {
        return "now";
      }
      return "${minutesDifference}m";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: chatRoomData[kKeyLastMessage] == ''? true : false,
      child: ListTile(
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
            ? RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: chatRoomData[kKeyLastMessage],
                        style: TextStyle(
                            color: chatRoomData[kKeyIsSeen]
                                ? Colors.grey
                                : Colors.black,
                            fontWeight: chatRoomData[kKeyIsSeen]
                                ? FontWeight.normal
                                : FontWeight.bold,
                            letterSpacing: 0.5)),
                    TextSpan(
                        text: " . ${calculateDate(chatRoomData[kKeyTimestamp])}"),
                  ],
                ),
              )
            : Text(
                "You: ${chatRoomData[kKeyLastMessage]} . ${calculateDate(chatRoomData[kKeyTimestamp])}",
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.5),
              ),
        trailing: chatRoomData[kKeyIsSeen]
            ? null
            : chatRoomData[kKeySenderId] == userData[kKeyUsersId] ? Container(
                width: 10.0,
                height: 10.0,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ) : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagingScreen(
                  userData: userData, chatRoomId: chatRoomData[kKeyChatRoomId]),
            ),
          );
        },
      ),
    );
  }
}
