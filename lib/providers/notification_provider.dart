import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void increment() {
    _unreadCount++;
    notifyListeners();
  }

  void decrement() {
    _unreadCount--;
    notifyListeners();
  }

  void reset() {
    _unreadCount = 0;
    notifyListeners();
  }

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}
