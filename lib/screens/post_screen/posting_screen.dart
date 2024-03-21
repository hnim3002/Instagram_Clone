import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:instagram_clon/Widgets/custom_divider_widgets.dart';
import 'package:instagram_clon/resources/firestore_method.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../Widgets/custom_button_widgets.dart';
import '../../models/user.dart' as model;
import '../../models/user.dart';
import '../../providers/posts_provider.dart';
import '../../providers/posts_state_provider.dart';
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
      String postId = const Uuid().v1();
      String res = await FirestoreMethods().uploadPost(
          caption: _postController.text.trim(),
          username: username,
          file:  await compressImage(widget.file, 80),
          uid: uid,
          userPhotoUrl: userPhotoUrl,
          postId: postId);
      await FirestoreMethods().updateUserPost(postId, uid, true);
      if(res == "success") {
      } else {
        print(res);
      }
    } catch (e) {
      print(e);
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

  Future<void> getPostData() async {
    Provider.of<PostsStateProvider>(context, listen: false).setPostDataSize(await Provider.of<PostsProvider>(context, listen: false).initPostData());
  }

  Future<void> _showDialog(BuildContext context, User user) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.0, // Set the desired width
                  height: 20.0, // Set the desired height
                  child: CircularProgressIndicator(strokeWidth: 3.0),
                ),
                SizedBox(width: 10,),
                Text('Processing...'), // Processing text
              ],
            ),
          ),

        );
      },
    );
    
    await postImage(user.uid.toString(), user.username.toString(), user.photoUrl.toString());
    await getPostData();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.popUntil(context, (route) => route.isFirst);
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
                          _showDialog(context, user!);
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
