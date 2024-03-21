
import 'package:flutter/cupertino.dart';


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
    notifyListeners();
  }
}
