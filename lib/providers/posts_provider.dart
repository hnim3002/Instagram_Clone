
import 'package:flutter/cupertino.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/const.dart';

import '../models/user.dart';

class PostsProvider with ChangeNotifier {
  List<Map<String, dynamic>>? _postData = [];
  List<Map<String, dynamic>> _subPostData = [];
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  int? postIndex;


  List<Map<String, dynamic>> get subPostData => _subPostData;

  List<Map<String, dynamic>>? get postData => _postData;

  void resetSubPostData() {
    _subPostData = [];
  }

  Future<int> initPostData() async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getPostsData();
    _postData = commentData;
    notifyListeners();
    return commentData.length;
  }


  Future<void> refreshPostData() async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getPostsData();
    _postData = commentData;
    notifyListeners();
  }


  Future<void> refreshNumberOfComment() async {
    _postData![postIndex!]['comment'] = _postData![postIndex!]['comment'] + 1;
    notifyListeners();
  }

  Future<void> refreshSubNumberOfComment() async {
    _subPostData[0]['comment'] = _subPostData[0]['comment'] + 1;
    notifyListeners();
  }

  Future<void> refreshNumberOfLike(bool isLike, String uid) async {
    if(isLike) {
      _postData![postIndex!]['post'][kKeyLike].add(uid);
    } else {
      _postData![postIndex!]['post'][kKeyLike].remove(uid);
    }
    notifyListeners();
  }
  Future<void> refreshSubNumberOfLike(bool isLike, String uid) async {
    if(isLike) {
      _subPostData[0]['post'][kKeyLike].add(uid);
    } else {
      _subPostData[0]['post'][kKeyLike].remove(uid);
    }
    notifyListeners();
  }

  Future<int> getAllUserPost(String uid) async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getUserPost(uid);
    _subPostData = commentData;
    notifyListeners();
    return commentData.length;
  }

  Future<int> getAPost(String postId) async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getAPost(postId);
    _subPostData = commentData;
    notifyListeners();
    return commentData.length;
  }


}
