import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdomwalk/models/user.dart';
import 'package:wisdomwalk/utils/constants.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    
    if (userData != null) {
      final extractedData = json.decode(userData) as Map<String, dynamic>;
      _token = extractedData['token'];
      _user = User.fromJson(extractedData['user']);
      notifyListeners();
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null && _user != null) {
      prefs.setString('userData', json.encode({
        'token': _token,
        'user': _user!.toJson(),
      }));
    } else {
      prefs.remove('userData');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        _error = responseData['message'] ?? 'Authentication failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _token = responseData['data']['token'];
      _user = User.fromJson(responseData['data']['user']);
      
      _isLoading = false;
      _saveUserData();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Could not connect to server. Please try again later.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _saveUserData();
    notifyListeners();
  }

  Future<bool> getProfile() async {
    if (_token == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        _error = responseData['message'] ?? 'Failed to get profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = User.fromJson(responseData['data']);
      
      _isLoading = false;
      _saveUserData();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Could not connect to server. Please try again later.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
