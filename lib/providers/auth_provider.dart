import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    final token = await _storage.read(key: 'access_token');

    _isLoggedIn = (prefs.getBool('isLoggedIn') ?? false) && (token != null);

    if (_isLoggedIn) {
      _userEmail = await _storage.read(key: 'user_email');
      _userName = await _storage.read(key: 'user_name');
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final responseData = await _apiService.login(email, password);

      if (responseData != null && responseData.containsKey('token')) {
        final prefs = await SharedPreferences.getInstance();

        final token = responseData['token'].toString();
        final userJson = responseData['user'] as Map<String, dynamic>;
        final userName = userJson['fullName'].toString();
        final userEmail = userJson['email'].toString();

        await prefs.setBool('isLoggedIn', true);
        await _storage.write(key: 'access_token', value: token);
        await _storage.write(key: 'user_email', value: userEmail);
        await _storage.write(key: 'user_name', value: userName);

        _isLoggedIn = true;
        _userEmail = userEmail;
        _userName = userName;

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Auth Error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    await _storage.deleteAll();

    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;

    notifyListeners();
  }
}
