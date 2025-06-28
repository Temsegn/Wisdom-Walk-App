import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/services/auth_service.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _localStorageService = LocalStorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  ThemeMode _themeMode = ThemeMode.light;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeUser();
    _loadThemePreference();
  }

  get user => null;

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _localStorageService.getAuthToken();
      if (token != null) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadThemePreference() async {
    final isDarkMode = await _localStorageService.getDarkModePreference();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _localStorageService.setDarkModePreference(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String city,
    required String subcity,
    required String country,
    required String idImagePath,
    required String faceImagePath,
    Uint8List? idImageBytes,
    Uint8List? faceImageBytes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider registering with: firstName=$firstName, lastName=$lastName, email=$email, password=$password'); // Debug log
      final user = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        city: city,
        subcity: subcity,
        country: country,
        idImagePath: idImagePath,
        faceImagePath: faceImagePath,
        idImageBytes: idImageBytes,
        faceImageBytes: faceImageBytes, fullName: '',
      );

      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      print('Registration error: $e'); // Debug log
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.verifyOtp(email: email, otp: otp);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendOtp({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resendOtp(email: email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email: email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? city,
    String? subcity,
    String? country,
    String? avatarPath,
    List<String>? wisdomCircleInterests,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        userId: _currentUser!.id,
        firstName: firstName,
        lastName: lastName,
        city: city,
        subcity: subcity,
        country: country,
        avatarPath: avatarPath,
        wisdomCircleInterests: wisdomCircleInterests,
      );

      _currentUser = updatedUser;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      await _localStorageService.clearAuthToken();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}