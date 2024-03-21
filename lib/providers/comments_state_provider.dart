
import 'package:flutter/cupertino.dart';


class CommentsStateProvider with ChangeNotifier {
  bool _isReplying = false;
  bool _isViewReply = false;
  String commentId = '';
  Map<String, dynamic> userComment = {};
  int? commentIndex;

  bool get isReplying => _isReplying;

  void setIsReplying() {
    _isReplying ? _isReplying = false : _isReplying = true;
    notifyListeners();
  }

  bool get isViewReply => _isViewReply;

  void setIsViewReply() {
    _isViewReply  ? _isViewReply  = false : _isViewReply = true;
    notifyListeners();
  }

  void resetState() {
    _isReplying = false;
    _isViewReply = false;
    commentIndex = null;
  }
}
