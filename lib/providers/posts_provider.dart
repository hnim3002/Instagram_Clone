
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

  Future<void> refreshNumberOfLike(bool isLike, String uid) async {
    if(isLike) {
      _postData![postIndex!]['post'][kKeyLike].add(uid);
    } else {
      _postData![postIndex!]['post'][kKeyLike].remove(uid);
    }
    notifyListeners();
  }

  Future<int> initSubPostData(String uid) async {
    List<Map<String, dynamic>>?  commentData = await _firestoreMethods.getUserPost(uid);
    _subPostData = commentData;
    notifyListeners();
    return commentData.length;
  }


}
