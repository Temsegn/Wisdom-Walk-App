// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wisdomwalk/models/user_model.dart';
// import 'package:wisdomwalk/providers/user_provider.dart';
// import 'package:wisdomwalk/services/auth_service.dart';
// import 'package:wisdomwalk/services/local_storage_service.dart';
// import 'package:go_router/go_router.dart';

// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();
//   final LocalStorageService _localStorageService = LocalStorageService();

//   UserModel? _currentUser;
//   bool _isLoading = false;
//   String? _error;
//   ThemeMode _themeMode = ThemeMode.light;

//   UserModel? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   ThemeMode get themeMode => _themeMode;
//   bool get isAuthenticated => _currentUser != null;

//   AuthProvider() {
//     _loadThemePreference();
//     _loadUserFromToken(); // Load user if token exists
//   }
//   void setCurrentUser(UserModel? user) {
//     _currentUser = user;
//     notifyListeners();
//   }

//   Future<void> _loadThemePreference() async {
//     final isDarkMode = await _localStorageService.getDarkModePreference();
//     _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }

//   Future<void> refreshUser(BuildContext context) async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     await userProvider.fetchCurrentUser(forceRefresh: true);
//     if (userProvider.currentUser.id.isNotEmpty) {
//       setCurrentUser(userProvider.currentUser);
//     } else {
//       setCurrentUser(null);
//     }
//   }

//   Future<void> toggleThemeMode() async {
//     _themeMode =
//         _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     await _localStorageService.setDarkModePreference(
//       _themeMode == ThemeMode.dark,
//     );
//     notifyListeners();
//   }

//   Future<void> _loadUserFromToken() async {
//     final token = await _localStorageService.getAuthToken();
//     print('Loading token from SharedPreferences: $token'); // Debug log
//     if (token == null) {
//       print('No token found, user not logged in');
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     try {
//       _isLoading = true;
//       notifyListeners();
//       final user = await _authService.getCurrentUser();
//       print('User fetched: ${user.id}, ${user.email}'); // Debug log
//       _currentUser = user;
//     } catch (e) {
//       print('Auto-login failed: $e');
//       // Only clear token on specific errors (e.g., invalid token)
//       if (e.toString().contains('401') ||
//           e.toString().contains('Invalid token')) {
//         await _localStorageService.clearAuthToken();
//         print('Token cleared due to invalid token');
//       }
//       _currentUser = null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> register({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String password,
//     required String city,
//     required String subcity,
//     required String country,
//     required String idImagePath,
//     required String faceImagePath,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _authService.register(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         password: password,
//         city: city,
//         subcity: subcity,
//         country: country,
//         idImagePath: idImagePath,
//         faceImagePath: faceImagePath,
//       );
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> verifyOtp({required String email, required String otp}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final verified = await _authService.verifyOtp(email: email, otp: otp);
//       return verified;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> login({required String email, required String password}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final user = await _authService.login(email: email, password: password);
//       _currentUser = user;
//       print('Login successful, user: ${user.id}, ${user.email}'); // Debug log
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       print('Login error: $e'); // Debug log
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> updateProfile({
//     String? firstName,
//     String? lastName,
//     String? city,
//     String? subcity,
//     String? bio,
//     String? country,
//     String? avatarPath,
//     List<String>? wisdomCircleInterests,
//   }) async {
//     if (_currentUser == null) return false;

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final updatedUser = await _authService.updateProfile(
//         userId: _currentUser!.id,
//         firstName: firstName,
//         lastName: lastName,
//         city: city,
//         country: country,
//         bio: bio,
//       );
//       _currentUser = updatedUser;
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> resendOtp({required String email}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _authService.resendOtp(email: email);
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> forgotPassword({required String email}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _authService.forgotPassword(email: email);
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> resetPassword({
//     required String email,
//     required String otp,
//     required String newPassword,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _authService.resetPassword(
//         email: email,
//         otp: otp,
//         newPassword: newPassword,
//       );
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> logout({BuildContext? context}) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await _authService.logout();
//       _currentUser = null;
//       if (context != null && context.mounted) {
//         context.push('/login'); // Navigate to login screen
//       }
//       return true;
//     } catch (e) {
//       _error = e.toString();
//       print('Logout error: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/providers/user_provider.dart';
import 'package:wisdomwalk/services/auth_service.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadThemePreference();
    _loadUserFromToken();
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUserAvatar(String newAvatarUrl) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatarUrl: newAvatarUrl);
      notifyListeners();
    }
  }

  Future<void> _loadThemePreference() async {
    final isDarkMode = await _localStorageService.getDarkModePreference();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> refreshUser(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchCurrentUser(forceRefresh: true);
    if (userProvider.currentUser.id.isNotEmpty) {
      setCurrentUser(userProvider.currentUser);
    } else {
      setCurrentUser(null);
    }
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
    debugPrint('Loading token from SharedPreferences: $token');
    if (token == null) {
      debugPrint('No token found, user not logged in');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();
      final user = await _authService.getCurrentUser();
      debugPrint('User fetched: ${user.id}, ${user.email}');
      _currentUser = user;
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      if (e.toString().contains('401') ||
          e.toString().contains('Invalid token')) {
        await _localStorageService.clearAuthToken();
        debugPrint('Token cleared due to invalid token');
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
      debugPrint('Login successful, user: ${user.id}, ${user.email}');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Login error: $e');
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
    List<String>? wisdomCircleInterests,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('https://wisdom-walk-app.onrender.com/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await _localStorageService.getAuthToken()}',
        },
        body: json.encode({
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (bio != null) 'bio': bio,
          if (city != null && country != null)
            'location': {'city': city, 'country': country},
          if (subcity != null) 'subcity': subcity,
          if (wisdomCircleInterests != null)
            'wisdomCircleInterests': wisdomCircleInterests,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = UserModel.fromJson(data['data']);
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update profile: ${response.body}';
        debugPrint(_error);
        return false;
      }
    } catch (e) {
      _error = 'Error updating profile: $e';
      debugPrint(_error);
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
      await _localStorageService.clearAuthData();
      _currentUser = null;
      if (context != null && context.mounted) {
        context.push('/login');
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Logout error: $e');
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
