import 'package:flutter/material.dart';
import 'package:NEIRA_COFFEE/models/user.dart';
import 'package:NEIRA_COFFEE/database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String username, String password) async {
    final user = await DatabaseHelper().login(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  bool hasRole(String role) {
    return _currentUser?.role == role;
  }
}
