import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/easeIn_animation_widget.dart';
import 'package:instagram_clon/providers/comments_state_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Widgets/comment_card_layout_widgets.dart';
import '../providers/comments_provider.dart';
import '../providers/posts_provider.dart';
import '../resources/firestore_method.dart';
import '../utils/color_schemes.dart';
import '../utils/const.dart';
import '../utils/utils.dart';
import '../Widgets/comment_card_widgets.dart';
import '../Widgets/post_card_widgets.dart';

class PostCommentLayout extends StatefulWidget {
  final String userPhoto;
  final String postId;
  final String uid;
  final String userName;
  const PostCommentLayout(
      {super.key,
      required this.userPhoto,
      required this.postId,
      required this.uid,
      required this.userName});

  @override
  State<PostCommentLayout> createState() => _PostCommentLayoutState();
}

class _PostCommentLayoutState extends State<PostCommentLayout> {
  String replyTo = "";
  bool isReply = false;
  late CachedNetworkImageProvider userImageProvider;
  TextEditingController commentController = TextEditingController();
  List<String> emojis = ["❤️", "🙌", "🔥", "👏", "😢", "😍", "😲", "😂"];

  Future<void> getCommentData() async {
    await Provider.of<CommentsProvider>(context, listen: false)
        .refreshCommentData();

  }

  Future<void> getReplyData() async {
    await Provider.of<CommentsProvider>(context, listen: false).getReplyData();
  }
  void moveUserToTop(List<Map<String, dynamic>> list, String specificUserId) {
    // Find the index of the user with the specific ID
    int index = list.indexWhere((element) =>
        element['user'] != null &&
        element['user'][kKeySenderId] == specificUserId);
    if (index != -1) {
      // If found, remove it from its current position
      Map<String, dynamic> user = list.removeAt(index);
      // Insert it at the beginning of the list
      list.insert(0, user);
    }
  }

  Future<void> uploadComment(
      String postId, String uid, String commentContent) async {
    try {
      String res = await FirestoreMethods().uploadPostComment(
          postId: postId, uid: uid, commentContent: commentContent);
      if (res == "success") {
      } else {
        if (!context.mounted) return;
        showSnackBar(res, context);
      }
    } catch (e) {
      print(e);
    }
  }

  void refreshNumberOfComment() {
    Provider.of<PostsProvider>(context, listen: false).refreshNumberOfComment();
  }

  Future<void> uploadReplyComment(String postId, String uid,
      String replyContent, String commentsId, String receiverId) async {
    try {
      String res = await FirestoreMethods().uploadReplyComment(
          postId: postId,
          uid: uid,
          receiverId: receiverId,
          commentContent: replyContent,
          parentId: commentsId);
      if (res == "success") {
      } else {
        if (!context.mounted) return;
        showSnackBar(res, context);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getNumberOfReply() async {
    await Provider.of<CommentsProvider>(context, listen: false).updateNumberOfReply();
  }

  void onReplyPress() {
    commentController.text += "@${widget.userName} ";
    Provider.of<CommentsStateProvider>(context, listen: false).setIsReplying();
    setState(() {
      isReply = true;
    });
  }

  void onEmojiPress(String emoji) {
    commentController.text += emoji;
  }

  @override
  void initState() {
    Provider.of<CommentsProvider>(context, listen: false).setPostId(widget.postId);
    getCommentData();
    getNumberOfReply();
    userImageProvider = CachedNetworkImageProvider(widget.userPhoto);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            Container(
              width: 40,
              height: 5, // Height of the divider
              margin: const EdgeInsets.symmetric(
                  vertical: 10), // Adjust vertical spacing
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                color: Colors.grey[700], // Divider color
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Comments",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Expanded(
              child: Provider.of<CommentsProvider>(context).commentData == null
                  ? Container()
                  : ListView.builder(
                      itemCount:
                          Provider.of<CommentsProvider>(context, listen: false)
                              .commentData!
                              .length,
                      itemBuilder: (BuildContext context, int index) {
                        return CommentCardLayout(
                          commentData: Provider.of<CommentsProvider>(context,
                                  listen: false)
                              .commentData![index],
                          uid: widget.uid,
                          onReplyPress: () => onReplyPress(),
                          index: index,
                        );
                      },
                    ),
            ),

            // Expanded(
            //   child: ValueListenableBuilder<List<Map<String, dynamic>>?>(
            //     valueListenable: commentDataFuture,
            //     builder: (BuildContext context,
            //         List<Map<String, dynamic>>? value, Widget? child) {
            //       if (value == null) {
            //         return const Center(
            //           child: SizedBox(
            //             width: 50.0, // Adjust width as needed
            //             height: 50.0, // Adjust height as needed
            //             child: CircularProgressIndicator(),
            //           ),
            //         );
            //       }
            //       if (value.isEmpty) {
            //         return const Center(
            //             child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Text(
            //               "No comments yet",
            //               style: TextStyle(
            //                   fontWeight: FontWeight.bold, fontSize: 23),
            //             ),
            //             SizedBox(
            //               height: 10,
            //             ),
            //             Text(
            //               "Start the conversation.",
            //               style: TextStyle(fontSize: 13, color: Colors.grey),
            //             )
            //           ],
            //         ));
            //       }
            //       return ListView.builder(
            //         itemCount: value.length,
            //         itemBuilder: (BuildContext context, int index) {
            //           print("listView.rebuli");
            //           return CommentCardLayout(
            //             commentData: value[index],
            //             uid: widget.uid,
            //             onReplyPress: () => onReplyPress(), index: index,
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),

            // Expanded(
            //   child: FutureBuilder<List<Map<String, dynamic>>>(
            //     key: UniqueKey(),
            //     future: commentDataFuture,
            //     builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         // Show a loading indicator while fetching data
            //         return const Center(
            //           child: SizedBox(
            //             width: 50.0, // Adjust width as needed
            //             height: 50.0, // Adjust height as needed
            //             child: CircularProgressIndicator(),
            //           ),
            //         );
            //       }
            //       if(snapshot.hasError) {
            //         return Text('Error: ${snapshot.error}');
            //       }
            //       if(snapshot.data!.isNotEmpty) {
            //         return ListView.builder(
            //           itemCount: snapshot.data!.length,
            //           itemBuilder: (BuildContext context, int index) {
            //             return CommentCard(
            //               commentData: snapshot.data![index],
            //               uid: widget.uid,
            //               onReplyPress:() => onReplyPress(),
            //             );
            //           },
            //         );
            //       }
            //       return const Center(
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Text(
            //               "No comments yet",
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 23
            //               ),
            //             ),
            //             SizedBox(height: 10,),
            //             Text(
            //               "Start the conversation.",
            //               style: TextStyle(
            //                 fontSize: 13,
            //                 color: Colors.grey
            //               ),
            //             )
            //           ],
            //         )
            //       );
            //     },
            //   ),
            // ),
            Column(
              children: [
                Visibility(
                  visible: isReply,
                  maintainAnimation: true,
                  maintainState: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isReply ? 1 : 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border(
                              top: BorderSide(
                                  color: Colors.grey.shade300, width: 0.5))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Replying to $replyTo",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            IconButton(
                                visualDensity: VisualDensity.compact,
                                highlightColor: Colors.transparent,
                                enableFeedback: false,
                                color: Colors.black,
                                iconSize: 25,
                                onPressed: () {
                                  Provider.of<CommentsStateProvider>(context,
                                          listen: false)
                                      .setIsReplying();
                                  setState(() {
                                    isReply = false;
                                  });
                                },
                                icon: Icon(
                                  Symbols.close_rounded,
                                  color: Colors.grey[600],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade300, width: 0.5))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: emojis.map((emoji) {
                        return IconButton(
                            visualDensity: VisualDensity.compact,
                            highlightColor: Colors.transparent,
                            enableFeedback: false,
                            color: Colors.black,
                            onPressed: () {
                              onEmojiPress(emoji);
                            },
                            icon: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ));
                      }).toList()),
                ),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade300, width: 0.5))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: userImageProvider,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: 45,
                          child: ElevatedButton(
                            onPressed: () async {

                              if (!Provider.of<CommentsStateProvider>(context, listen: false).isReplying) {
                                await uploadComment(widget.postId, widget.uid,
                                    commentController.text);
                                await getNumberOfReply();
                                getCommentData();
                              } else {
                                await uploadReplyComment(
                                    widget.postId,
                                    widget.uid,
                                    commentController.text,
                                    Provider.of<CommentsProvider>(context, listen: false)
                                        .commentData?[Provider.of<CommentsStateProvider>(
                                            context,
                                            listen: false)
                                        .commentIndex!]["post"][kKeyCommentId],
                                    Provider.of<CommentsProvider>(context, listen: false)
                                            .commentData?[
                                        Provider.of<CommentsStateProvider>(
                                                context,
                                                listen: false)
                                            .commentIndex!]["user"][kKeyUsersId]);
                                await getNumberOfReply();
                                getReplyData();

                              }
                              commentController.clear();
                              refreshNumberOfComment();
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: blueBtnColor),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
