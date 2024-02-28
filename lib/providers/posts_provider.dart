
import 'package:flutter/cupertino.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/const.dart';

import '../models/user.dart';

class PostsProvider with ChangeNotifier {
  List<Map<String, dynamic>>? _postData = [];
  List<List<dynamic>> listOfLike = [];
  List<int> numberOfComment = [];
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  int? postIndex;


  List<Map<String, dynamic>>? get postData => _postData;


  Future<void> refreshPostData() async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getPostsData(listOfLike, numberOfComment);
    _postData = commentData;
    notifyListeners();
  }

  Future<void> updatePostData(int index, Map<String, dynamic> updatedPostData) async {
    // Map<String, dynamic> postData = await _firestoreMethods.updatePostData(_postData?[postIndex!]['post'][kKeyPostId]);

    _postData![index]['post'] = updatedPostData;
    // _postData![postIndex!] = postData;
  }

  Future<void> refreshNumberOfComment() async {
    numberOfComment = await _firestoreMethods.getNumberOfComment();
    notifyListeners();
  }

  Future<void> refreshNumberOfLike() async {
    listOfLike = await _firestoreMethods.getNumberOfLike();
    notifyListeners();
  }
}
