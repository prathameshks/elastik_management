import 'package:flutter/foundation.dart';
import 'package:elastik_management/utils/auth_manager.dart';
import 'package:elastik_management/utils/data_loader.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await AuthManager.isLoggedIn();
    if (!_isLoggedIn) {
      clearUser();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final foundUser = await DataLoader.getUserByEmail(email);

    if (foundUser != null) {
      
      _isLoggedIn = true;

      setUser(foundUser);
      return foundUser;
    }
    return null;
  }

  Future<void> logout() async {
    await AuthManager.logout();
    _isLoggedIn = false;
    clearUser();
  }
}