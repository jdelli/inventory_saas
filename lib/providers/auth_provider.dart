import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _userRole = prefs.getString('userRole');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Dummy authentication - in real app, this would be an API call
    if (email == 'admin@inventory.com' && password == 'password') {
      _isAuthenticated = true;
      _userId = 'user_001';
      _userName = 'Admin User';
      _userEmail = email;
      _userRole = 'admin';
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', _userId!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('userEmail', _userEmail!);
      await prefs.setString('userRole', _userRole!);
      
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userRole = null;
    
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    
    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('userName', name);
    if (email != null) await prefs.setString('userEmail', email);
    
    notifyListeners();
  }
}
