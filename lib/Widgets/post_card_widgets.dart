import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/like_animation_widgets.dart';
import 'package:instagram_clon/resources/firestore_method.dart';

import 'package:instagram_clon/utils/const.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/comments_provider.dart';
import '../providers/posts_provider.dart';
import '../screens/post_comment_screen.dart';

class PostCard extends StatefulWidget {
  final User user;
  final int index;
  final bool isSub;
  const PostCard(
      {super.key, required this.user, required this.index, this.isSub = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isSmallLike = false;
  bool isLike = false;
  bool isAnimation = false;
  bool isFollowing = false;
  late String postPhotoUrl;
  late String userPhotoUrl;
  late String userName;
  late String caption;
  late List like;
  late Timestamp timestamp;
  bool isLoading = true; // Track loading state
  int i = 0;
  late ImageStreamListener _userImageStreamListener;
  late ImageStreamListener _postImageStreamListener;
  late CachedNetworkImageProvider _userImageProvider;
  late CachedNetworkImageProvider _postImageProvider;
  late var commentProvider ;

  @override
  void initState() {
    super.initState();
    commentProvider = Provider.of<CommentsProvider>(context, listen: false);
    if (widget.isSub) {
      postPhotoUrl = Provider.of<PostsProvider>(context, listen: false)
          .subPostData[widget.index]["post"][kKeyPostPhoto];
      userPhotoUrl = Provider.of<PostsProvider>(context, listen: false)
          .subPostData[widget.index]["user"][kKeyUserPhoto];
      userName = Provider.of<PostsProvider>(context, listen: false)
          .subPostData[widget.index]["user"][kKeyUserName];
      caption = Provider.of<PostsProvider>(context, listen: false)
          .subPostData[widget.index]["post"][kKeyCaption];
      if (Provider.of<PostsProvider>(context, listen: false)
          .subPostData[widget.index]["user"][kKeyUserFollowers]
          .contains(widget.user.uid)) {
        isFollowing = true;
      }
    } else {
      postPhotoUrl = Provider.of<PostsProvider>(context, listen: false)
          .postData![widget.index]["post"][kKeyPostPhoto];
      userPhotoUrl = Provider.of<PostsProvider>(context, listen: false)
          .postData![widget.index]["user"][kKeyUserPhoto];
      userName = Provider.of<PostsProvider>(context, listen: false)
          .postData![widget.index]["user"][kKeyUserName];
      caption = Provider.of<PostsProvider>(context, listen: false)
          .postData![widget.index]["post"][kKeyCaption];
      if (Provider.of<PostsProvider>(context, listen: false)
          .postData![widget.index]["user"][kKeyUserFollowers]
          .contains(widget.user.uid)) {
        isFollowing = true;
      }
    }

    timestamp = Provider.of<PostsProvider>(context, listen: false)
        .postData![widget.index]["post"][kKeyTimestamp];

    _userImageProvider = CachedNetworkImageProvider(userPhotoUrl);
    _userImageStreamListener = ImageStreamListener((_, __) => _updateCounter());

    _postImageProvider = CachedNetworkImageProvider(postPhotoUrl);
    _postImageStreamListener = ImageStreamListener((_, __) => _updateCounter());

    // Listen to the image stream for the user photo
    _userImageProvider
        .resolve(ImageConfiguration.empty)
        .addListener(_userImageStreamListener);

    // Listen to the image stream for the post photo
    _postImageProvider
        .resolve(ImageConfiguration.empty)
        .addListener(_postImageStreamListener);
  }

  Future<void> onLikePress() async {
    if (widget.isSub) {
      if (!Provider.of<PostsProvider>(context, listen: false)
          .subPostData[widget.index]["post"][kKeyLike]
          .contains(widget.user.uid!)) {
        for (var i = 0;
            i <
                Provider.of<PostsProvider>(context, listen: false)
                    .postData!
                    .length;
            i++) {
          if (Provider.of<PostsProvider>(context, listen: false)
                  .postData![i]
                  .toString() ==
              Provider.of<PostsProvider>(context, listen: false)
                  .subPostData[0]
                  .toString()) {
            Provider.of<PostsProvider>(context, listen: false).postIndex = i;
            Provider.of<PostsProvider>(context, listen: false)
                .refreshNumberOfLike(
                    !Provider.of<PostsProvider>(context, listen: false)
                        .postData![widget.index]["post"][kKeyLike]
                        .contains(widget.user.uid!),
                    widget.user.uid!);
          }
        }
        Provider.of<PostsProvider>(context, listen: false)
            .refreshSubNumberOfLike(
                !Provider.of<PostsProvider>(context, listen: false)
                    .subPostData[widget.index]["post"][kKeyLike]
                    .contains(widget.user.uid!),
                widget.user.uid!);
        await FirestoreMethods().updateLikePost(
            Provider.of<PostsProvider>(context, listen: false)
                .subPostData[widget.index]["post"][kKeyPostId],
            widget.user.uid!,
            !isLike);
      }
    } else {
      if (!Provider.of<PostsProvider>(context, listen: false)
          .postData![widget.index]["post"][kKeyLike]
          .contains(widget.user.uid!)) {
        Provider.of<PostsProvider>(context, listen: false).refreshNumberOfLike(
            !Provider.of<PostsProvider>(context, listen: false)
                .postData![widget.index]["post"][kKeyLike]
                .contains(widget.user.uid!),
            widget.user.uid!);
        await FirestoreMethods().updateLikePost(
            Provider.of<PostsProvider>(context, listen: false)
                .postData![widget.index]["post"][kKeyPostId],
            widget.user.uid!,
            !isLike);
      }
    }
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('MMMM d, y').format(dateTime);
    return formattedDate;
  }

  void _updateCounter() {
    i++;
    if (i >= 2) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userImageProvider
        .resolve(ImageConfiguration.empty)
        .removeListener(_userImageStreamListener);
    _postImageProvider
        .resolve(ImageConfiguration.empty)
        .removeListener(_postImageStreamListener);
    super.dispose();
  }

  Future<void> showDeleteDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              InkWell(
                onTap: () {
                  FirestoreMethods().deletePost(
                      Provider.of<PostsProvider>(context, listen: false)
                          .postData![widget.index]["post"][kKeyPostId]);
                  getPostData();
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text("Delete"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Future<void> getPostData() async {
    await Provider.of<PostsProvider>(context, listen: false).refreshPostData();
  }

  @override
  Widget build(BuildContext context) {

    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    bool isLike;
    int numberOfLike;
    int numberOfComment;
    if (widget.isSub) {
      isLike = Provider.of<PostsProvider>(context)
          .subPostData[widget.index]["post"][kKeyLike]
          .contains(widget.user.uid!);
      numberOfLike = Provider.of<PostsProvider>(context)
          .subPostData[widget.index]["post"][kKeyLike]
          .length;
      numberOfComment = Provider.of<PostsProvider>(context)
          .subPostData[widget.index]["comment"];
    } else {
      isLike = Provider.of<PostsProvider>(context)
          .postData![widget.index]["post"][kKeyLike]
          .contains(widget.user.uid!);
      numberOfLike = Provider.of<PostsProvider>(context)
          .postData![widget.index]["post"][kKeyLike]
          .length;
      numberOfComment = Provider.of<PostsProvider>(context)
          .postData![widget.index]["comment"];
    }

    return !isLoading
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: _userImageProvider,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Expanded(child: SizedBox()),
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        highlightColor: Colors.transparent,
                        enableFeedback: false,
                        color: isDarkMode ? Colors.white : Colors.black,
                        iconSize: 25,
                        onPressed: () {
                          showDeleteDialog(context);
                        },
                        icon: const Icon(
                          Symbols.more_vert_rounded,
                          weight: 500,
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onDoubleTap: () async {
                  Provider.of<PostsProvider>(context, listen: false).postIndex =
                      widget.index;
                  setState(() {
                    isAnimation = true;
                    isSmallLike = true;
                  });

                  await onLikePress();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image(image: _postImageProvider),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isAnimation ? 1 : 0,
                      child: LikeAnimation(
                        isAnimating: isAnimation,
                        child: const Icon(
                          Symbols.favorite,
                          shadows: <Shadow>[
                            Shadow(color: Colors.black, blurRadius: 1.0)
                          ],
                          fill: 1,
                          color: Colors.white,
                          size: 100,
                        ),
                        onEnd: () {
                          setState(() {
                            isAnimation = false;
                          });
                          isSmallLike = false;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    LikeAnimation(
                      isAnimating: isSmallLike,
                      onEnd: () {
                        setState(() {
                          isSmallLike = false;
                        });
                      },
                      child: IconButton(
                          visualDensity: VisualDensity.compact,
                          highlightColor: Colors.transparent,
                          enableFeedback: false,
                          color: isDarkMode ? Colors.white : Colors.black,
                          iconSize: 25,
                          onPressed: () async {
                            isSmallLike = true;
                            if (widget.isSub) {
                              for (var i = 0;
                                  i < Provider.of<PostsProvider>(context,
                                              listen: false)
                                          .postData!
                                          .length;
                                  i++) {
                                if (Provider.of<PostsProvider>(context,
                                            listen: false)
                                        .postData![i]
                                        .toString() ==
                                    Provider.of<PostsProvider>(context,
                                            listen: false)
                                        .subPostData[0]
                                        .toString()) {
                                  Provider.of<PostsProvider>(context, listen: false).postIndex = i;

                                  Provider.of<PostsProvider>(context,
                                          listen: false)
                                      .refreshNumberOfLike(
                                          !Provider.of<PostsProvider>(context,
                                                  listen: false)
                                              .subPostData[widget.index]["post"]
                                                  [kKeyLike]
                                              .contains(widget.user.uid!),
                                          widget.user.uid!);
                                }
                              }
                              Provider.of<PostsProvider>(context, listen: false)
                                  .refreshSubNumberOfLike(
                                      !Provider.of<PostsProvider>(context,
                                              listen: false)
                                          .subPostData[widget.index]["post"]
                                              [kKeyLike]
                                          .contains(widget.user.uid!),
                                      widget.user.uid!);
                              await FirestoreMethods().updateLikePost(
                                  Provider.of<PostsProvider>(context,
                                              listen: false)
                                          .subPostData[widget.index]["post"]
                                      [kKeyPostId],
                                  widget.user.uid!,
                                  !isLike);
                            } else {
                              Provider.of<PostsProvider>(context, listen: false)
                                  .refreshNumberOfLike(
                                      !Provider.of<PostsProvider>(context,
                                              listen: false)
                                          .postData![widget.index]["post"]
                                              [kKeyLike]
                                          .contains(widget.user.uid!),
                                      widget.user.uid!);
                              await FirestoreMethods().updateLikePost(
                                  Provider.of<PostsProvider>(context,
                                              listen: false)
                                          .postData![widget.index]["post"]
                                      [kKeyPostId],
                                  widget.user.uid!,
                                  !isLike);
                            }
                          },
                          icon: isLike
                              ? const Icon(Symbols.favorite,
                                  fill: 1, color: Colors.red)
                              : const Icon(
                                  Symbols.favorite,
                                  weight: 500,
                                )),
                    ),
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        highlightColor: Colors.transparent,
                        enableFeedback: false,
                        color: isDarkMode ? Colors.white : Colors.black,
                        iconSize: 25,
                        onPressed: () {
                          Provider.of<PostsProvider>(context, listen: false)
                              .postIndex = widget.index;
                          showBottomSheet();
                        },
                        icon: const Icon(
                          Symbols.mode_comment_rounded,
                          weight: 500,
                        )),
                    const Expanded(child: SizedBox()),
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        highlightColor: Colors.transparent,
                        enableFeedback: false,
                        color: isDarkMode ? Colors.white : Colors.black,
                        iconSize: 25,
                        onPressed: () {},
                        icon: const Icon(
                          Symbols.share,
                          weight: 500,
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$numberOfLike likes"),
                    ExpandableText(
                      caption,
                      expandText: ' more',
                      maxLines: 2,
                      prefixText: userName,
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                      animation: true,
                      linkColor: Colors.blue,
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<PostsProvider>(context, listen: false)
                            .postIndex = widget.index;
                        showBottomSheet();
                      },
                      child: Text(
                        "View all ${numberOfComment} comment",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                    Text(
                      formatDate(timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          )
        : const PostCardPlaceHolder();
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        useSafeArea: true,
        context: context,

        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              if (didPop) {
                return;
              }
              Provider.of<CommentsProvider>(context, listen: false).numberOfReply = [];
              Provider.of<CommentsProvider>(context, listen: false).deleteCommentData();
              Provider.of<CommentsProvider>(context, listen: false).deleteReplyData();
              Navigator.pop(context);
            },
            child: PostCommentLayout(
              userPhoto: widget.user.photoUrl.toString(),
              postId: widget.isSub
                  ? Provider.of<PostsProvider>(context, listen: false)
                      .subPostData[widget.index]["post"][kKeyPostId]
                  : Provider.of<PostsProvider>(context, listen: false)
                      .postData![widget.index]["post"][kKeyPostId],
              uid: widget.user.uid.toString(),
              userName: widget.user.username.toString(), isSub: widget.isSub,
            ),
          );
        },
     ).whenComplete(() {
       List<int> temp = [];
       commentProvider.numberOfReply = temp;
       commentProvider.deleteCommentData();
       commentProvider.deleteReplyData();
    });
  }
}

class PostCardPlaceHolder extends StatelessWidget {
  const PostCardPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                width: 40,
                height: 7, // Height of the divider
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  color: Colors.grey[300], // Divider color
                ),
              ),
              const Expanded(child: SizedBox()),
              IconButton(
                  visualDensity: VisualDensity.compact,
                  highlightColor: Colors.transparent,
                  enableFeedback: false,
                  color: Colors.black,
                  iconSize: 25,
                  onPressed: () {},
                  icon: const Icon(
                    Symbols.more_vert_rounded,
                    weight: 500,
                  )),
            ],
          ),
        ),
        Container(
          height: 300,
          color: Colors.grey[300],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 7,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    color: Colors.grey[300], // Divider color
                  ),
                ),
                Container(
                  width: 300,
                  height: 7,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    color: Colors.grey[300], // Divider color
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
