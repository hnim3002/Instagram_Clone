import 'dart:async';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import '../../Widgets/message_bubble_widgets.dart';
import '../../utils/const.dart';
import '../search_screen/user_profile_info_screen.dart';
import 'img_picker_messaging.dart';

class MessagingScreen extends StatefulWidget {
  final String? chatRoomId;
  final Map<String, dynamic> userData;
  const MessagingScreen({super.key, required this.userData, required this.chatRoomId});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {


  final TextEditingController _controller = TextEditingController();
  bool _isTextFieldEmpty = true;
  bool _emojiShowing = false;
  String chatRoomId = '';

  late final Stream<QuerySnapshot> chatRoomStream;

  Future<void> createRoom() async {
    String id =  await FirestoreMethods().uploadChatRoom(uid: FirebaseAuth.instance.currentUser!.uid, receiverId: widget.userData[kKeyUsersId]);
    if (!mounted) return;
    setState(() {
      chatRoomId = id;
    });
  }

  @override
  void initState() {
    super.initState();
    if(widget.chatRoomId == '') {
      createRoom();
    } else {
      chatRoomId = widget.chatRoomId!;
    }

    chatRoomStream = FirebaseFirestore.instance
        .collection(kKeyCollectionChatRooms)
        .doc(widget.chatRoomId)
        .collection(kKeySubCollectionMessages)
        .orderBy(kKeyTimestamp, descending: true)
        .snapshots();
    _controller.addListener(_handleTextFieldChange);
  }

  int calculateDifferenceInMinutes(DateTime time1, DateTime time2) {
    Duration difference = time2.difference(time1);
    int differenceInMinutes = difference.inMinutes.abs();
    return differenceInMinutes;
  }

  Future<void> sendImage(dynamic file) async {
    await FirestoreMethods().uploadChatMessageImg(
        uid: FirebaseAuth.instance.currentUser!.uid,
        file: await compressImage(await convertToUint8List(file), 80),
        chatRoomId: chatRoomId );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<Uint8List> convertToUint8List(img) async {
    return await img.readAsBytes();
  }

  Future<Uint8List> compressImage(Uint8List imageBytes, int quality) async {
    try {
      final compressedImageBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality, // Compression quality (0 to 100)
      );
      return compressedImageBytes;
    } catch (e) {
      print('Error compressing image: $e');
      return imageBytes;
    }
  }

  Future<XFile?> getImgCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    return photo;
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            expand: false,
            snap: true,
            snapSizes: const [0.7, 1],
            initialChildSize: 0.7, // this is initial fraction of the screen that the sheet takes up
            minChildSize: 0.25, // 25% of screen height
            maxChildSize: 1, //
            builder: (BuildContext context, ScrollController scrollController) {
              return ImgPickerMessaging(scrollController: scrollController, chatRoomId: chatRoomId,);
            },
          );
        });
  }

  StreamBuilder<QuerySnapshot<Object?>> buildStreamBuilder() {
    return  StreamBuilder<QuerySnapshot>(
        stream:chatRoomStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  const CircularProgressIndicator();
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            reverse: true,

            itemBuilder: (context, index) {

              int position = 0;

              var message = snapshot.data!.docs[index];
              bool isYou =
              snapshot.data!.docs[index][kKeySenderId] == FirebaseAuth.instance.currentUser!.uid
                  ? true
                  : false;

              bool isVisible;

              bool isSeenVisible = false;

              var previousMessageTime;
              var previousMessageUserName;
              var nextMessageTime;
              var nextMessageUserName;

              if(index != 0) {
                previousMessageTime =
                    snapshot.data!.docs[index - 1][kKeyTimestamp].toDate();
                previousMessageUserName =
                snapshot.data!.docs[index - 1][kKeySenderId];
              }
              if(index != snapshot.data!.docs.length - 1) {
                nextMessageTime =
                    snapshot.data!.docs[index + 1][kKeyTimestamp].toDate();
                nextMessageUserName = snapshot.data!.docs[index + 1][kKeySenderId];
              }


              var currentMessageTime =
              snapshot.data!.docs[index][kKeyTimestamp].toDate();


              var currentUserName = FirebaseAuth.instance.currentUser!.uid;

              if (isYou) {
                if (index == 0) {
                  if (calculateDifferenceInMinutes(
                      nextMessageTime, currentMessageTime) <
                      5 &&
                      nextMessageUserName == currentUserName) {
                    position = 1;
                  } else if (nextMessageUserName == currentUserName &&
                      calculateDifferenceInMinutes(
                          nextMessageTime, currentMessageTime) >=
                          5 ||
                      nextMessageUserName != currentUserName) {
                    position = 0;
                  }
                } else if (index == snapshot.data!.docs.length - 1) {
                  if (calculateDifferenceInMinutes(
                      previousMessageTime, currentMessageTime) <
                      5 &&
                      previousMessageUserName == currentUserName) {
                    position = 3;
                  } else if (previousMessageUserName == currentUserName &&
                      calculateDifferenceInMinutes(
                          previousMessageTime, currentMessageTime) >=
                          5 ||
                      previousMessageUserName != currentUserName) {
                    position = 0;
                  }
                } else {
                  if (previousMessageUserName != currentUserName &&
                      nextMessageUserName == currentUserName &&
                      calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                          5 ||
                      calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5 &&
                          calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                              5) {
                    position = 1;
                  } else if (previousMessageUserName == currentUserName &&
                      nextMessageUserName == currentUserName &&
                      calculateDifferenceInMinutes(
                          previousMessageTime, currentMessageTime) <
                          5 &&
                      calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                          5) {
                    position = 2;
                  } else if (previousMessageUserName == currentUserName &&
                      nextMessageUserName != currentUserName &&
                      calculateDifferenceInMinutes(
                          previousMessageTime, currentMessageTime) <
                          5 ||
                      calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) >= 5 &&
                          calculateDifferenceInMinutes(
                              previousMessageTime, currentMessageTime) <
                              5) {
                    position = 3;
                  } else if (previousMessageUserName != currentUserName &&
                      nextMessageUserName != currentUserName ||
                      previousMessageUserName == currentUserName &&
                          nextMessageUserName == currentUserName &&
                          calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) >= 5 &&
                          calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5) {
                    position = 0;
                  }
                }
              } else {
                if (index == 0) {
                  if (calculateDifferenceInMinutes(
                      nextMessageTime, currentMessageTime) <
                      5 &&
                      nextMessageUserName != currentUserName) {
                    position = 1;
                  } else if (nextMessageUserName != currentUserName &&
                      calculateDifferenceInMinutes(
                          nextMessageTime, currentMessageTime) >=
                          5 ||
                      nextMessageUserName == currentUserName) {
                    position = 0;
                  }
                } else if (index == snapshot.data!.docs.length - 1) {
                  if (calculateDifferenceInMinutes(
                      previousMessageTime, currentMessageTime) <
                      5 &&
                      previousMessageUserName != currentUserName) {
                    position = 6;
                  } else if (previousMessageUserName != currentUserName &&
                      calculateDifferenceInMinutes(
                          previousMessageTime, currentMessageTime) >=
                          5 ||
                      previousMessageUserName == currentUserName) {
                    position = 0;
                  }
                } else {
                  if (previousMessageUserName == currentUserName &&
                      nextMessageUserName != currentUserName &&
                      calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                          5 ||
                      calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5 &&
                          calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                              5) {
                    position = 4;
                  } else if (previousMessageUserName != currentUserName &&
                      nextMessageUserName != currentUserName &&
                      calculateDifferenceInMinutes(
                          previousMessageTime, currentMessageTime) <
                          5 &&
                      calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) <
                          5) {
                    position = 5;
                  } else if (previousMessageUserName != currentUserName &&
                      nextMessageUserName == currentUserName ||
                      calculateDifferenceInMinutes(nextMessageTime, currentMessageTime) >= 5 &&
                          calculateDifferenceInMinutes(
                              previousMessageTime, currentMessageTime) <
                              5) {
                    position = 6;
                  } else if (previousMessageUserName != currentUserName &&
                      nextMessageUserName != currentUserName ||
                      previousMessageUserName == currentUserName &&
                          nextMessageUserName == currentUserName &&
                          calculateDifferenceInMinutes(
                              nextMessageTime, currentMessageTime) >=
                              5 &&
                          calculateDifferenceInMinutes(previousMessageTime, currentMessageTime) >= 5) {
                    position = 0;
                  }
                }
              }

              bool isTimestampVisible = index == snapshot.data!.docs.length - 1 ||
                  calculateDifferenceInMinutes(
                      snapshot.data!.docs[index + 1]['timestamp'].toDate(),
                      snapshot.data!.docs[index]['timestamp'].toDate()) >= 60 ||
                  position == 3 ||
                  position == 6
                  ? true
                  : false;

              if(index == 0 && isYou && message[kKeyIsSeen] == true) {
                isSeenVisible = true;
              }

              return MessageBubble(
                text: message[kKeyMessageContent],
                isUser: isYou,
                position: position,
                isTimestampVisible: isTimestampVisible,
                isSeenVisible: isSeenVisible,
                timestamp: message[kKeyTimestamp],
                userPhoto: widget.userData[kKeyUserPhoto],
                messageType: message[kKeyMessageType],
              );
            },
          );
        }
    );
  }

  @override
  void dispose() {

    _controller.dispose();
    super.dispose();
  }

  void _handleTextFieldChange() {
    bool isTextFieldCurrentlyEmpty = _controller.text.isEmpty;
    if (_isTextFieldEmpty != isTextFieldCurrentlyEmpty) {
      setState(() {
        _isTextFieldEmpty = isTextFieldCurrentlyEmpty;
      });
    }
  }

  void toggleEmojiShowing() {
    setState(() {
      _emojiShowing = !_emojiShowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: UserListTileInfo(widget: widget),
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0.0,
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }

            if(_emojiShowing) {
              setState(() {
                _emojiShowing = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              if(_emojiShowing) {
                setState(() {
                  _emojiShowing = false;
                });
              }
            },
            child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: buildStreamBuilder()),
                    InputLayout(
                      onEmojiPressed: () => toggleEmojiShowing(),
                      isEmojiShowing: _emojiShowing,
                      chatRoomId: chatRoomId,
                      onImgPress: () => showBottomSheet(),
                      onCameraPress: () async {
                        sendImage(await getImgCamera());
                      },
                    ),
                    Offstage(
                      offstage: !_emojiShowing,
                      child: EmojiPicker(
                        textEditingController: _controller,
                        config: Config(
                          height: 256,

                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 8,
                            // Issue: https://github.com/flutter/flutter/issues/28894
                            emojiSizeMax: 28 *
                                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                                    ? 1.2
                                    : 1.0),
                          ),

                          skinToneConfig: const SkinToneConfig(),
                          categoryViewConfig: const CategoryViewConfig(),
                          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),

                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
        )
    );
  }
}

class InputLayout extends StatefulWidget {
  const InputLayout({
    super.key,
    required this.onEmojiPressed, required this.isEmojiShowing, required this.chatRoomId, required this.onImgPress, required this.onCameraPress,
  });

  final Function onCameraPress;
  final Function onImgPress;
  final Function onEmojiPressed;
  final bool isEmojiShowing;
  final String chatRoomId;
  @override
  State<InputLayout> createState() => _InputLayoutState();
}

class _InputLayoutState extends State<InputLayout> {
  final TextEditingController controller = TextEditingController();
  bool isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleTextFieldChange);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleTextFieldChange() {
    bool isTextFieldCurrentlyEmpty = controller.text.isEmpty;
    if (isTextFieldEmpty != isTextFieldCurrentlyEmpty) {
      setState(() {
        isTextFieldEmpty = isTextFieldCurrentlyEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFEEEEEE),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTextFieldEmpty ? Colors.blue : Colors.white,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: isTextFieldEmpty ? Colors.white : Colors.blue,
                iconSize: 24,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  widget.onEmojiPressed();
                },
                icon: isTextFieldEmpty
                    ? const Icon(
                  Symbols.mood_rounded,
                  fill: 1,
                )
                    : const Icon(Symbols.mood_rounded),
              )
            ],
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextField(
              maxLines: null,
              controller: controller,
              onTap: () {
                if(widget.isEmojiShowing) {
                  widget.onEmojiPressed();
                }
              },
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Message...',
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                //Do something with the user input.
              },
            ),
          ),
          isTextFieldEmpty
              ? Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.black,
                iconSize: 27,
                onPressed: () {},
                icon: const Icon(
                  Symbols.mic_rounded,
                  opticalSize: 40,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.black,
                iconSize: 27,
                onPressed: () {
                  widget.onImgPress();
                },
                icon: const Icon(
                  Symbols.image_rounded,
                  opticalSize: 40,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.black,
                iconSize: 27,
                onPressed: () {
                  widget.onCameraPress();
                },
                icon: const Icon(
                  Symbols.photo_camera,
                  opticalSize: 40,
                ),
              ),
            ],
          )
              : Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 37,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.white,
                iconSize: 23,
                onPressed: () {
                  FirestoreMethods().uploadChatMessageText(uid: FirebaseAuth.instance.currentUser!.uid, messageContent: controller.text.trim(), chatRoomId: widget.chatRoomId);
                  controller.clear();
                },
                icon: const Icon(
                  Icons.send_rounded,
                  fill: 1,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}



class UserListTileInfo extends StatelessWidget {
  const UserListTileInfo({
    super.key,
    required this.widget,
  });

  final MessagingScreen widget;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CachedNetworkImage(
        imageUrl: widget.userData[kKeyUserPhoto],
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 17,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      title: Text(
        widget.userData[kKeyFullName],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        widget.userData[kKeyUserName],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: UserProfileInfoScreen(
                  uid: widget.userData[kKeyUsersId],
                )));
      },
    );
  }
}




