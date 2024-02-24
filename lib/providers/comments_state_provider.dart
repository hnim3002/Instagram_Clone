
import 'package:flutter/cupertino.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/resources/firestore_method.dart';

import '../models/user.dart';

class CommentsStateProvider with ChangeNotifier {
  bool _isReplying = false;
  bool _isViewReply = false;
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
