import 'package:flutter/material.dart';
import 'package:vocal_odyssey/services/auth_service.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null && _token != null;

  void setUser(User user, String token) {
    _user = user;
    _token = token;
    AuthService.saveUser(user, token);
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    AuthService.updateUser(user);
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final user = await AuthService.getUser();
    final token = await AuthService.getToken();
    if (user != null && token != null) {
      _user = user;
      _token = token;
    }
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = null;
    AuthService.logout();
    notifyListeners();
  }
}
