import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boostseller/model/user_model.dart';
import 'package:boostseller/model/hostess_model.dart';
import 'package:boostseller/model/performer_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = UserModel.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<void> setUser(UserModel user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('auth_token');
    await prefs.remove('isApproved');
    notifyListeners();
  }

  void updateAvatar(String newAvatar) {
    if (_user != null) {
      _user = _user!.copyWith(avatarPath: newAvatar);
    }
  }

  void updateHostess(HostessModel updatedHostess) {
    if (_user != null) {
      _user = _user?.copyWith(hostess: updatedHostess);
      notifyListeners();
    }
  }

  void updatePerformer(PerformerModel updatedPerformer) {
    if (_user != null) {
      _user = _user?.copyWith(performer: updatedPerformer);
      notifyListeners();
    }
  }
}
