import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/like_animation_widgets.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/color_schemes.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/comments_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/user_provider.dart';
import '../utils/utils.dart';
import '../screens/post_comment_screen.dart';

class PostCard extends StatefulWidget {
  final User user;
  final Map<String, dynamic> combinedData;
  final int index;
  const PostCard({super.key, required this.combinedData, required this.user, required this.index});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isSmallLike = false;
  bool isLike = false;
  bool isAnimation = false;
  int numberOfLike = 0;
  int numberOfComment = 0;
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

  @override
  void initState() {
    super.initState();

    postPhotoUrl = widget.combinedData["post"][kKeyPostPhoto];
    userPhotoUrl = widget.combinedData["user"][kKeyUserPhoto];
    userName = widget.combinedData["user"][kKeyUserName];
    caption = widget.combinedData["post"][kKeyCaption];
    like = widget.combinedData["post"][kKeyLike];
    numberOfLike = like.length;
    numberOfComment = widget.combinedData["comment"];
    if (like.contains(widget.user.uid)) {
      isLike = true;
    }
    timestamp = widget.combinedData["post"][kKeyTimestamp];

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

  Future<void> getPostData() async {
    //await Provider.of<PostsProvider>(context, listen: false).updatePostData();
    //await Provider.of<PostsProvider>(context, listen: false).refreshPostData();
  }

  Future<void> getLikeData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(kKeyCollectionPosts)
        .doc(widget.combinedData["post"][kKeyPostId])
        .get();
    if (documentSnapshot.exists) {
      setState(() {
        like = documentSnapshot.get(kKeyLike);
        if (like.contains(widget.user.uid)) {
          isLike = true;
        }
      });
    } else {
      print('Document does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
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
                        onPressed: () {},
                        icon: const Icon(
                          Symbols.more_vert_rounded,
                          weight: 500,
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onDoubleTap: () async {
                  Provider.of<PostsProvider>(context, listen: false).postIndex = widget.index;
                  setState(() {
                    isAnimation = true;
                    if (!isLike) {
                      numberOfLike++;
                    }
                    isLike = true;
                    isSmallLike = true;
                  });
                  if (!isLike) {
                    await FirestoreMethods().updateLikePost(
                        widget.combinedData["post"][kKeyPostId],
                        widget.user.uid!,
                        isLike);
                    getPostData();
                  }
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
                            Provider.of<PostsProvider>(context, listen: false).postIndex = widget.index;
                            setState(() {
                              isSmallLike = true;
                              if (isLike) {
                                numberOfLike--;
                                isLike = false;
                              } else {
                                numberOfLike++;
                                isLike = true;
                              }
                            });

                            await FirestoreMethods().updateLikePost(
                                widget.combinedData["post"][kKeyPostId],
                                widget.user.uid!,
                                isLike);
                            getPostData();
                          },
                          icon: isLike
                              ? const Icon(
                                  Symbols.favorite,
                                  fill: 1,
                                  color: Colors.red,
                                )
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
                          Provider.of<PostsProvider>(context, listen: false).postIndex = widget.index;
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
                        Provider.of<PostsProvider>(context, listen: false).postIndex = widget.index;
                      },
                      child: Text(
                        "View all ${Provider.of<PostsProvider>(context).numberOfComment[widget.index]} comment",
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
          return PostCommentLayout(
            userPhoto: widget.user.photoUrl.toString(),
            postId: widget.combinedData["post"][kKeyPostId],
            uid: widget.user.uid.toString(),
            userName: widget.user.username.toString(),
          );
        }).then((_) {
      Provider.of<CommentsProvider>(context, listen: false).numberOfReply = [];
      Provider.of<CommentsProvider>(context, listen: false).deleteCommentData();
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
