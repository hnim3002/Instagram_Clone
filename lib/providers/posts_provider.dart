
import 'package:flutter/cupertino.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/const.dart';

import '../models/user.dart';

class PostsProvider with ChangeNotifier {
  List<Map<String, dynamic>>? _postData = [];
  List<List<dynamic>> listOfLike = [];
  List<int> listOfComment = [];
  List<Map<String, dynamic>>? _subPostData = [];
  List<List<dynamic>> subListOfLike = [];
  List<int> subListOfComment = [];
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  int? postIndex;


  List<Map<String, dynamic>>? get postData => _postData;


  Future<void> refreshPostData() async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getPostsData(listOfLike, listOfComment);
    _postData = commentData;
    notifyListeners();
  }

  Future<void> updatePostData(int index, Map<String, dynamic> updatedPostData) async {
    // Map<String, dynamic> postData = await _firestoreMethods.updatePostData(_postData?[postIndex!]['post'][kKeyPostId]);

    _postData![index]['post'] = updatedPostData;
    // _postData![postIndex!] = postData;
  }

  Future<void> refreshNumberOfComment() async {
    listOfComment = await _firestoreMethods.getNumberOfComment();
    _postData![postIndex!]['comment'] = updatedPostData;
    notifyListeners();
  }

  Future<void> refreshNumberOfLike(bool isLike, String uid) async {
    if(isLike) {
      listOfLike[postIndex!].add(uid);
    } else {
      listOfLike[postIndex!].remove(uid);
    }
    notifyListeners();
  }

  Future<void> refreshSubPostData(String uid) async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getUserPost(uid, subListOfLike, subListOfComment);
    _subPostData = commentData;
    notifyListeners();
  }


}
