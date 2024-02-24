import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:instagram_clon/Widgets/custom_divider_widgets.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../Widgets/custom_button_widgets.dart';
import '../../models/user.dart' as model;
import '../../providers/user_provider.dart';

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

  Future<void> postImage(
      String uid, String username, String userPhotoUrl) async {
    try {
      String res = await FirestoreMethods().uploadPost(
          caption: _postController.text.trim(),
          username: username,
          file:  await compressImage(widget.file, 80),
          uid: uid,
          userPhotoUrl: userPhotoUrl);
      if(res == "success") {
        if (!context.mounted) return;
        showSnackBar("Posted!", context);
      } else {
        if (!context.mounted) return;
        showSnackBar(res , context);
      }
    } catch (e) {
      showSnackBar(e.toString() , context);
    }
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
    final model.User? user = Provider.of<UserProvider>(context).user;
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return  Scaffold(
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
                      const SizedBox(height: 20,),
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
                        onPressed: () {
                          if(user != null) {
                            postImage(user.uid.toString(), user.username.toString(), user.photoUrl.toString());
                          }
                        },
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
