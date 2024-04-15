import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/color_schemes.dart';

class NotificationListTile extends StatefulWidget {
  final Map<String, dynamic> notificationData;

  const NotificationListTile({super.key, required this.notificationData});

  @override
  State<NotificationListTile> createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<NotificationListTile> {

  late String uid;
  late String photoUrl;
  late String content;
  late String type;
  late Timestamp timestamp;
  late bool isBtnActive;


  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() {
    uid = widget.notificationData["user"][kKeyUsersId];
    photoUrl = widget.notificationData["user"][kKeyUserPhoto];
    content = widget.notificationData["notification"][kKeyNotificationContent];
    type = widget.notificationData["notification"][kKeyNotificationType];
    timestamp = widget.notificationData["notification"][kKeyTimestamp];
    isBtnActive = Provider.of<UserProvider>(context, listen: false).user!.isUserFollowing(uid);
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: photoUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 23,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      title: Text(content, style: const TextStyle(fontSize: 14)),
      subtitle: Text("12h"),
      trailing: type == "follow" ? ElevatedButton(
          onPressed: () {
            setState(() {
              isBtnActive = !isBtnActive;
            });
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
          )) : null,

      onTap: () {

      },
    );
  }
}
