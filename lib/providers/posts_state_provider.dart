
import 'package:flutter/cupertino.dart';
import 'package:instagram_clon/resources/auth_method.dart';
import 'package:instagram_clon/resources/firestore_method.dart';
import 'package:instagram_clon/utils/const.dart';

import '../models/user.dart';

class PostsStateProvider with ChangeNotifier {
  int _postDataSize = 0;
  int _subPostDataSize = 0;

  int get postDataSize => _postDataSize;

  void setPostDataSize(int value) {
    _postDataSize = value;
    notifyListeners();
  }

  int get subPostDataSize => _subPostDataSize;

  void getSubPostDataSize(int value) {
    _subPostDataSize = value;
  }
}
