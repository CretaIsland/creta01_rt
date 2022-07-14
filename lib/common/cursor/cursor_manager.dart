import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/util/logger.dart';

enum MyPageCursor {
  basic,
  precise, // spoid
}

//CursorManager? cursorManagerHolder;

class CursorManager extends ChangeNotifier {
  // factory CursorManager.singleton() {
  //   return CursorManager();
  // }
  MyPageCursor _cursorType = MyPageCursor.basic;

  void setCursor(MyPageCursor value) {
    _cursorType = value;
    notifyListeners();
  }

  void setNormal() {
    if (_cursorType != MyPageCursor.basic) {
      _cursorType = MyPageCursor.basic;
      notifyListeners();
    }
  }

  bool isSnippet() {
    return _cursorType == MyPageCursor.precise;
  }

  SystemMouseCursor getCursor() {
    logHolder.log('getCursor=$_cursorType');
    switch (_cursorType) {
      case MyPageCursor.basic:
        return SystemMouseCursors.basic;
      case MyPageCursor.precise:
        return SystemMouseCursors.precise;
      default:
        return SystemMouseCursors.basic;
    }
  }
}
