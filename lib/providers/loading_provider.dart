// Loading state management : made by Leo on 2025/05/09

import 'package:flutter/material.dart';

class LoadingProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
