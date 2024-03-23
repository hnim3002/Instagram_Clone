import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.text,
      required this.isUser,
      required this.position,
      required this.isTimestampVisible,
      required this.isSeenVisible,
      required this.timestamp,
      required this.userPhoto,
      required this.messageType});

  final String text;
  final bool isUser;
  final int position;
  final bool isTimestampVisible;
  final bool isSeenVisible;
  final Timestamp timestamp;
  final String userPhoto;
  final String messageType;

  BorderRadius borderCustomIsUser() {
    if (position == 3) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(10.0),
      );
    } else if (position == 2) {
      return const BorderRadius.only(
        topRight: Radius.circular(10.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(10.0),
      );
    } else if (position == 0) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      );
    }
    return const BorderRadius.only(
      topRight: Radius.circular(10.0),
      topLeft: Radius.circular(30.0),
      bottomLeft: Radius.circular(30.0),
      bottomRight: Radius.circular(30.0),
    );
  }

  BorderRadius borderCustomNotUser() {
    if (position == 4) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(10.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      );
    } else if (position == 5) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(10.0),
        bottomLeft: Radius.circular(10.0),
        bottomRight: Radius.circular(30.0),
      );
    } else if (position == 0) {
      return const BorderRadius.only(
        topRight: Radius.circular(30.0),
        topLeft: Radius.circular(30.0),
        bottomLeft: Radius.circular(30.0),
        bottomRight: Radius.circular(30.0),
      );
    }
    return const BorderRadius.only(
      topRight: Radius.circular(30.0),
      topLeft: Radius.circular(30.0),
      bottomLeft: Radius.circular(10.0),
      bottomRight: Radius.circular(30.0),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime object
    String formattedDateTime = DateFormat('MMM d, h:mm a').format(dateTime);

    return formattedDateTime;
  }

  Widget messageContent() {
    if (messageType == "text") {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: isUser ? borderCustomIsUser() : borderCustomNotUser(),
        ),
        color: isUser ? const Color(0xFF8523C4) : const Color(0xFFEEEEEE),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Text(text,
              style: TextStyle(
                  color: isUser ? Colors.white : Colors.black, fontSize: 15.0)),
        ),
      );
    } else if (messageType == "image") {
      return CachedNetworkImage(
          imageUrl: text,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          imageBuilder: (context, imageProvider) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(image: imageProvider),
                ),
              ));
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Offstage(
              offstage: !isTimestampVisible,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  formatTimestamp(timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ))),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 2 / 3,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Opacity(
                  opacity: !isUser && position == 0 || position == 4 ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: CachedNetworkImageProvider(userPhoto),
                    ),
                  ),
                ),
                messageContent(),
              ],
            ),
          ),
          Offstage(
            offstage: !isSeenVisible,
            child: const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "Seen",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
          position == 1 || position == 0 || position == 4
              ? const SizedBox(height: 10)
              : const SizedBox(height: 0),
        ],
      ),
    );
  }
}
