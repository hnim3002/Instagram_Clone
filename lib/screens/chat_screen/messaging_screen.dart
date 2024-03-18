import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import '../../utils/const.dart';
import '../search_screen/user_profile_info_screen.dart';

class MessagingScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MessagingScreen({super.key, required this.userData});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isTextFieldEmpty = true;
  bool _emojiShowing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextFieldChange);
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
    print('MessagingScreen build');
    return Scaffold(
      appBar: AppBar(title: UserListTileInfo(widget: widget)),
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
                children: [
                  Expanded(child: MessageContent(widget: widget)),
                  InputLayout(
                    onEmojiPressed: () => toggleEmojiShowing(), isEmojiShowing: _emojiShowing,
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
    required this.onEmojiPressed, required this.isEmojiShowing,
  });

  final Function onEmojiPressed;
  final bool isEmojiShowing;
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
                      onPressed: () {},
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
                      onPressed: () {},
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
                      onPressed: () {},
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

class MessageContent extends StatelessWidget {
  const MessageContent({
    super.key,
    required this.widget,
  });

  final MessagingScreen widget;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
        ),
        const SizedBox(
          height: 10,
        ),
        CachedNetworkImage(
          imageUrl: widget.userData[kKeyUserPhoto],
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 55,
            backgroundImage: imageProvider,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          widget.userData[kKeyFullName],
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Instagram: ${widget.userData[kKeyUserName]}",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
            "${widget.userData[kKeyUserFollowers].length} Followers : ${widget.userData[kKeyUserPost].length} posts",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            )
        ),
        ListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),
            Container(
              color: Colors.grey,
              height: 100,
              child: Text("slkfjsldkfjsdlkjf"),
            ),

          ],
        )
      ]),
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
