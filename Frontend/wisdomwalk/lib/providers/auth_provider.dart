import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/services/auth_service.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:go_router/go_router.dart';

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
    _loadThemePreference();
    _loadUserFromToken(); // Load user if token exists
  }

  Future<void> _loadThemePreference() async {
    final isDarkMode = await _localStorageService.getDarkModePreference();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _localStorageService.setDarkModePreference(
      _themeMode == ThemeMode.dark,
    );
    notifyListeners();
  }

  Future<void> _loadUserFromToken() async {
    final token = await _localStorageService.getAuthToken();
    print('Loading token from SharedPreferences: $token'); // Debug log
    if (token == null) {
      print('No token found, user not logged in');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();
      final user = await _authService.getCurrentUser();
      print('User fetched: ${user.id}, ${user.email}'); // Debug log
      _currentUser = user;
    } catch (e) {
      print('Auto-login failed: $e');
      // Only clear token on specific errors (e.g., invalid token)
      if (e.toString().contains('401') ||
          e.toString().contains('Invalid token')) {
        await _localStorageService.clearAuthToken();
        print('Token cleared due to invalid token');
      }
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        city: city,
        subcity: subcity,
        country: country,
        idImagePath: idImagePath,
        faceImagePath: faceImagePath,
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

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final verified = await _authService.verifyOtp(email: email, otp: otp);
      return verified;
    } catch (e) {
      _error = e.toString();
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
      print('Login successful, user: ${user.id}, ${user.email}'); // Debug log
      return true;
    } catch (e) {
      _error = e.toString();
      print('Login error: $e'); // Debug log
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
    String? bio,
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
        country: country,
        bio: bio,
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

  Future<bool> logout({BuildContext? context}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      if (context != null && context.mounted) {
        context.push('/login'); // Navigate to login screen
      }
      return true;
    } catch (e) {
      _error = e.toString();
      print('Logout error: $e');
      return false;
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
