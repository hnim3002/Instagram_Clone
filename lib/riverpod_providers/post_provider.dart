
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../resources/firestore_method.dart';



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
    var postData = await _firestoreMethods.getPostsData();
    state = AsyncData(postData);
  }

  Future<void> AddPost() async {
    var postData = await _firestoreMethods.getPostsData();
    state = AsyncData(postData);
  }



}