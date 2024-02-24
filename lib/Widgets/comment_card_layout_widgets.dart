import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../providers/comments_provider.dart';
import '../providers/comments_state_provider.dart';
import '../resources/firestore_method.dart';
import '../utils/const.dart';
import 'comment_card_widgets.dart';
import 'like_animation_widgets.dart';

class CommentCardLayout extends StatefulWidget {
  final int index;
  final String uid;
  final Map<String, dynamic> commentData;
  final Function onReplyPress;

  const CommentCardLayout({
    super.key,
    required this.commentData,
    required this.uid,
    required this.onReplyPress,
    required this.index,
  });

  @override
  State<CommentCardLayout> createState() => _CommentCardLayoutState();
}

class _CommentCardLayoutState extends State<CommentCardLayout> {
  int numberOfReply = 0;
  bool isViewReply = false;

  Future<void> getCommentAndReplyCounts() async {
    int replyCount = 0;

    QuerySnapshot replySnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .doc(widget.commentData["post"][kKeyPostId])
        .collection(kKeySubCollectionComment)
        .where(kKeyParentId,
            isEqualTo: widget.commentData["post"][kKeyCommentId])
        .orderBy(kKeyTimestamp, descending: false)
        .get();
    replyCount += replySnapshot.size;

    if (mounted) {
      setState(() {
        numberOfReply = replyCount;
      });
    }
  }

  Future<void> getReplyData() async {
    await Provider.of<CommentsProvider>(context, listen: false).getReplyData();
  }

  @override
  void initState() {
    getCommentAndReplyCounts();
    super.initState();
  }

  List<Widget> replyList() {
    List<Widget> replyList = [];
    // for (int i = 0; i < replyDataFuture.value!.length; i++) {
    //   var reply = CommentCardLayout(
    //     commentData: replyDataFuture.value![i],
    //     uid: widget.uid,
    //     onReplyPress: () => widget.onReplyPress(),
    //     index: i,
    //   );
    //   replyList.add(reply);
    // }

    for (int i = 0;
        i <
            Provider.of<CommentsProvider>(context)
                .replyData![widget.commentData['post'][kKeyCommentId]]
                .length;
        i++) {
      var reply = CommentCard(
        commentData: Provider.of<CommentsProvider>(context)
            .replyData?[widget.commentData['post'][kKeyCommentId]][i],
        uid: widget.uid,
        onReplyPress: () => widget.onReplyPress(),
        index: i,
        isReply: true,
      );
      replyList.add(reply);
    }
    return replyList;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<CommentsProvider>(context).numberOfReply == [] ? Container(child: Text("kljadsklds"),) : Column(
      children: [
        CommentCard(
          commentData: widget.commentData,
          uid: widget.uid,
          onReplyPress: widget.onReplyPress,
          index: widget.index,
        ),
        Visibility(
            visible: Provider.of<CommentsProvider>(context).numberOfReply[widget.index] == 0 ? false : true,
            child: !Provider.of<CommentsProvider>(context)
        .replyData!
        .containsKey(widget.commentData['post'][kKeyCommentId])
                ? GestureDetector(
                    onTap: () {
                      Provider.of<CommentsProvider>(context, listen: false).commentIndex = widget.index;
                      getReplyData();
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(67, 0, 0, 5),
                      child: Row(
                        children: [
                          const SizedBox(width: 30, child: Divider()),
                          const SizedBox(
                            width: 5,
                          ),
                          Text("View ${Provider.of<CommentsProvider>(context).numberOfReply[widget.index]} replies",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ))
                : Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: Column(children: replyList()),
                    )
            // : ValueListenableBuilder(
            //     valueListenable: replyDataFuture,
            //     builder: (BuildContext context, value, Widget? child) {
            //       if (value == null) {
            //         return const SizedBox();
            //       }
            //       return Transform.scale(
            //         scale: 0.95,
            //         child: Padding(
            //           padding: const EdgeInsets.only(left: 50),
            //           child: Column(children: replyList()),
            //         ),
            //       );
            //     },
            //   ),
            )
      ],
    );
  }
}
