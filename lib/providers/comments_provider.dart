import 'package:flutter/cupertino.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/const.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import 'comments_state_provider.dart';

class CommentsProvider with ChangeNotifier {
  String? _postId;
  List<Map<String, dynamic>>? _commentData;
  final Map<String, dynamic> _replyData = {};
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  List<int> numberOfReply = [];
  int? commentIndex;
  int? replyIndex;

  List<Map<String, dynamic>>? get commentData => _commentData;

  Map<String, dynamic>? get replyData => _replyData;

  void setPostId(String value) {
    _postId = value;
  }

  void deleteCommentData() {
    _commentData = null;
  }

  String? get postId => _postId;

  Future<void> refreshCommentData() async {
    List<Map<String, dynamic>>? commentData =
        await _firestoreMethods.getCommentData(_postId!);
    _commentData = commentData;
    print(_commentData);
    print(numberOfReply);
    notifyListeners();
  }

  Future<void> getReplyData() async {
    List<Map<String, dynamic>> replyData = await _firestoreMethods.getReplyData(
        _postId!, _commentData?[commentIndex!]["post"][kKeyCommentId]);
    _replyData[_commentData![commentIndex!]["post"][kKeyCommentId]] = replyData;
    print(_replyData[_commentData![commentIndex!]["post"][kKeyCommentId]]);
    notifyListeners();
  }

  Future<void> updateNumberOfReply() async {
    numberOfReply = await _firestoreMethods.getNumberOfReply(_postId!);
    notifyListeners();
  }
}
