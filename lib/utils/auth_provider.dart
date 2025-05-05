import 'package:elastik_management/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:elastik_management/utils/auth_manager.dart';
import 'package:elastik_management/utils/data_loader.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await AuthManager.isLoggedIn();
    if (_isLoggedIn) {
      final email = await AuthManager.getLoggedInUserEmail();
      if (email != null) {
        final user = await DataLoader.getUserByEmail(email);
        if (user != null) {
          setUser(user);
        } else {
          // User data not found, log them out
          logout();
        }
      }
    } else {
      clearUser();
    }
    notifyListeners();
  }

  Future<User?> login(String email, String password) async {
    final foundUser = await DataLoader.getUserByEmail(email);
    if (foundUser != null) {
      _isLoggedIn = true;
      await AuthManager.setLoggedIn(true, email: email);
      setUser(foundUser);
      return foundUser;
    }
    return null;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await AuthManager.logout();
    clearUser();
    notifyListeners();
  }

  Future<bool> isAdmin() async {
    return _user?.role == "admin";
  }
}