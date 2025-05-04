import 'package:flutter/foundation.dart';
import 'package:elastik_management/utils/auth_manager.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await AuthManager.isLoggedIn();
    notifyListeners();
  }

  Future<void> login() async {
    await AuthManager.login();
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthManager.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}