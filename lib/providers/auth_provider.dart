import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final ApiService _apiService = ApiService();

  Future<void> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String role,
    required String location,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: role,
        location: location,
      );

      _token = response['token'];
      // Load full profile data since auth response only has partial user info
      await loadProfile();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(
        phone: phone,
        password: password,
      );

      _token = response['token'];
      // Load full profile data since auth response only has partial user info
      await loadProfile();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (_token == null) return;

    try {
      _user = await _apiService.getProfile(_token!);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.updateProfile(_token!, {'isOnline': isOnline});
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}