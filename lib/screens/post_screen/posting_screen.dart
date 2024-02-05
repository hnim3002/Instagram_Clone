import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:instagram_clon/Widgets/CustomDivider_widgets.dart';

import '../../Widgets/CustomButton_widgets.dart';

class PostingScreen extends StatefulWidget {
  final Uint8List file;
  const PostingScreen({super.key, required this.file});

  @override
  State<PostingScreen> createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  final TextEditingController _postController = TextEditingController();
  late FocusNode _focusNode;
  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // TextField is in focus
      setState(() {
        isFocus = true;
      });
    } else {
      // TextField lost focus
      setState(() {
        isFocus = false;
      });
    }
  }

  void onBackPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        leading: IconButton(
          onPressed: () {
            onBackPressed();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        child: Center(
                          child: Image(
                            image: MemoryImage(widget.file),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _postController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Write a caption or add a poll',
                          ),
                        ),
                      ),
                      Container(
                          height: 50,
                          color: isFocus
                              ? Colors.grey
                              : isDarkMode
                                  ? Colors.black
                                  : Colors.white),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    const CustomDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomButton(
                        buttonContext: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Share',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
