import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../providers/comments_provider.dart';
import '../providers/comments_state_provider.dart';
import '../resources/firestore_method.dart';
import '../utils/const.dart';
import 'like_animation_widgets.dart';

class CommentCard extends StatefulWidget {
  final int index;
  final String uid;
  final Map<String, dynamic> commentData;
  final Function onReplyPress;
  final bool isReply;

  const CommentCard({
    super.key,
    required this.commentData,
    required this.uid,
    required this.onReplyPress,
    required this.index,
    this.isReply = false
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late String userName;
  late String commentContent;
  late List like;
  bool isLike = false;
  bool isAnimating = false;
  late String time;
  late int numberOfLike;
  late CachedNetworkImageProvider _userImageProvider;

  @override
  void initState() {
    userName = widget.commentData["user"][kKeyUserName];
    commentContent = widget.commentData["post"][kKeyCommentContent];
    like = widget.commentData["post"][kKeyLike];
    if (like.contains(widget.uid)) {
      isLike = true;
    }
    numberOfLike = like.length;
    time = calculateDate(widget.commentData["post"][kKeyTimestamp]);
    _userImageProvider =
        CachedNetworkImageProvider(widget.commentData["user"][kKeyUserPhoto]);
    super.initState();
  }

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
    } else {
      return "${hoursDifference}h";
    }
  }

  Future<void> updateLikeComment() async {
    await FirestoreMethods().updateLikeComment(
        widget.commentData["post"][kKeyPostId],
        widget.commentData["post"][kKeyCommentId],
        widget.uid,
        isLike);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: !widget.isReply ? 18 : 16,
                backgroundImage: _userImageProvider,
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: userName,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: "  $time",
                              style: const TextStyle(color: Colors.grey, ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      commentContent,
                      style: const TextStyle(height: 1.2, fontSize: 13),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                        onTap: () {
                          widget.onReplyPress();
                          Provider.of<CommentsStateProvider>(context, listen: false).commentIndex = widget.index;
                          Provider.of<CommentsProvider>(context, listen: false).commentIndex = widget.index;
                        },
                        child: const Text(
                          "Reply",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        )
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: !widget.isReply ? 1 : 0.9,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isAnimating = true;
                          if (isLike) {
                            numberOfLike--;
                            isLike = false;
                          } else {
                            numberOfLike++;
                            isLike = true;
                          }
                        });
                        await updateLikeComment();
                      },
                      child: LikeAnimation(
                        isAnimating: isAnimating,
                        onEnd: () {
                          setState(() {
                            isAnimating = false;
                          });
                        },
                        child: isLike
                            ? const Icon(
                          Symbols.favorite,
                          fill: 1,
                          color: Colors.red,
                        )
                            : const Icon(
                          Symbols.favorite,
                          weight: 500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text(numberOfLike.toString(), style: TextStyle(color: Colors.grey[700],),),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
