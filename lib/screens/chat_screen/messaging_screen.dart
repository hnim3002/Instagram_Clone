import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/user_card_widgets.dart';
import 'package:instagram_clon/utils/color_schemes.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: UserListTileInfo(widget: widget)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: MessageContent(widget: widget)),
              InputLayout(isTextFieldEmpty: _isTextFieldEmpty, controller: _controller),
            ],
          )
        )
    );
  }
}

class InputLayout extends StatelessWidget {
  const InputLayout({
    super.key,
    required bool isTextFieldEmpty,
    required TextEditingController controller,
  }) : _isTextFieldEmpty = isTextFieldEmpty, _controller = controller;

  final bool _isTextFieldEmpty;
  final TextEditingController _controller;

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
                  color: _isTextFieldEmpty ? Colors.blue : Colors.white,
                ),
              ),
              IconButton(
                  visualDensity: VisualDensity.compact,
                  highlightColor: Colors.transparent,
                  enableFeedback: false,
                  color: _isTextFieldEmpty ? Colors.white : Colors.blue,
                  iconSize: 24,
                  onPressed: () {

                  },
                  icon: _isTextFieldEmpty ? const Icon(Symbols.mood_rounded, fill: 1,) : const Icon(Symbols.mood_rounded),
              )
            ],
          ),
          const SizedBox(width: 5,),
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
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
          _isTextFieldEmpty ? Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,

                visualDensity: VisualDensity.compact,

                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.black,
                iconSize: 27,
                onPressed: () {

                },
                icon: const Icon(Symbols.mic_rounded, opticalSize: 40,),
              ),
              IconButton(
                padding: EdgeInsets.zero,

                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.black,
                iconSize: 27,
                onPressed: () {

                },
                icon: const Icon(Symbols.image_rounded, opticalSize: 40,),
              ),
              IconButton(
                padding: EdgeInsets.zero,

                visualDensity: VisualDensity.compact,
                highlightColor: Colors.transparent,
                enableFeedback: false,
                color: Colors.black,
                iconSize: 27,
                onPressed: () {

                },
                icon: const Icon(Symbols.photo_camera, opticalSize: 40,),
              ),
            ],
          ) : Stack(
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

                },
                icon: const Icon(Icons.send_rounded, fill: 1,),
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
      child: Column(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width,),
          const SizedBox(height: 10,),
          CachedNetworkImage(
            imageUrl: widget.userData[kKeyUserPhoto],
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 55,
              backgroundImage: imageProvider,
            ),
          ),
          const SizedBox(height: 20,),
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
        ]
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
