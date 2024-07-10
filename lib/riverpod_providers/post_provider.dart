
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/post.dart';
import '../resources/firestore_method.dart';
import '../resources/storage_method.dart';



part 'post_provider.g.dart';

// @riverpod
// class PostSizeNotifier extends _$PostSizeNotifier {
//   @override
//   int build() {
//     return 0;
//   }
//
//   void updateSize(int size) {
//     state = size;
//   }
// }

@riverpod
class PostNotifier extends _$PostNotifier {

  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    return await _firestoreMethods.getPostsData();
  }

  Future<void> updatePostData() async {
    try {
      state = const AsyncLoading();
      var postData = await _firestoreMethods.getPostsData();
      state = AsyncData(postData);
    } catch(e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> addPost(String caption, String uid, String postId, Uint8List file) async {


      state = const AsyncLoading();
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncError(
          Exception("CounterNotifier sample error..."), StackTrace.current);
      // String postPhotoUrl = await StorageMethods().uploadImageToStorage("post",file , true);
      // Post post = Post(
      //     postId: postId,
      //     uid: uid,
      //     postPhotoUrl: postPhotoUrl,
      //     timestamp: Timestamp.fromDate(DateTime.now()),
      //     caption: caption,
      //     like: []
      // );
      // String res = await FirestoreMethods().uploadPost(post);
      // updatePostData();

  }



}