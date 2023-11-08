import 'package:flutter/material.dart';

class MessageNotifier extends ChangeNotifier {
  int _unreadMessageCount = 0;

  int get unreadMessageCount => _unreadMessageCount;

  void updateUnreadMessageCount(int count) {
    _unreadMessageCount = count;
    notifyListeners();
  }
}