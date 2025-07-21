// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import 'package:wisdomwalk/services/local_storage_service.dart';
// import '../../models/user_model.dart';

// class UserService {
//   static const String baseUrl = 'https://wisdom-walk-app.onrender.com/api';
//   static final LocalStorageService _localStorageService = LocalStorageService();
//   static Future<List<UserModel>> searchUsers(String query) async {
//     try {
//       final token = await _localStorageService.getAuthToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication required');
//       }

//       final url = Uri.parse(
//         '$baseUrl/users/search?q=${Uri.encodeComponent(query)}',
//       );
//       debugPrint('Search Request: $url');

//       final response = await http
//           .get(
//             url,
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 30));

//       debugPrint('Search Response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['success'] == true) {
//           return (responseData['data'] as List)
//               .map((userJson) => UserModel.fromJson(userJson))
//               .toList();
//         }
//       }
//       throw Exception('Failed to search users');
//     } on TimeoutException {
//       throw Exception('Request timed out');
//     } catch (e) {
//       debugPrint('Search error: $e');
//       throw Exception('Search failed: ${e.toString()}');
//     }
//   }

//   static Future<UserModel> getCurrentUser() async {
//     try {
//       final token = await _localStorageService.getAuthToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication required - No token available');
//       }

//       final response = await http
//           .get(
//             Uri.parse('$baseUrl/users/profile'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 15));

//       debugPrint('Get Current User Response: ${response.statusCode}');
//       _validateResponse(response);

//       final responseData = json.decode(response.body);
//       final user = UserModel.fromJson(responseData['data']);
//       CurrentUser.setUser(user);
//       return user;
//     } on TimeoutException {
//       throw Exception('Request timed out');
//     } on FormatException {
//       throw Exception('Invalid server response format');
//     } catch (e) {
//       debugPrint('Get current user error: $e');
//       throw Exception('Failed to get current user: ${e.toString()}');
//     }
//   }

//   static Future<UserModel> getUserById(String userId) async {
//     try {
//       final token = await _localStorageService.getAuthToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication required - No token available');
//       }

//       final response = await http
//           .get(
//             Uri.parse('$baseUrl/users/$userId'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 15));

//       debugPrint('Get User by ID Response: ${response.statusCode}');
//       _validateResponse(response);

//       final responseData = json.decode(response.body);
//       return UserModel.fromJson(responseData['data']);
//     } on TimeoutException {
//       throw Exception('Request timed out');
//     } on FormatException {
//       throw Exception('Invalid server response format');
//     } catch (e) {
//       debugPrint('Get user by ID error: $e');
//       throw Exception('Failed to get user: ${e.toString()}');
//     }
//   }

//   static Future<List<UserModel>> getRecentUsers() async {
//     try {
//       final token = await _localStorageService.getAuthToken();
//       if (token == null || token.isEmpty) {
//         throw Exception('Authentication required - No token available');
//       }

//       final response = await http
//           .get(
//             Uri.parse('$baseUrl/users/users/recents'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 15));

//       debugPrint('Get Recent Users Response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         return (responseData['data'] as List)
//             .map((userJson) => UserModel.fromJson(userJson))
//             .toList();
//       }
//       return [];
//     } on TimeoutException {
//       throw Exception('Request timed out');
//     } on FormatException {
//       throw Exception('Invalid server response format');
//     } catch (e) {
//       debugPrint('Get recent users error: $e');
//       return [];
//     }
//   }

//   static void _validateResponse(http.Response response) {
//     if (response.statusCode != 200) {
//       final errorData = json.decode(response.body);
//       throw Exception(
//         errorData['message'] ??
//             'Request failed with status ${response.statusCode}',
//       );
//     }
//   }
// }

// class CurrentUser {
//   static UserModel? _user;

//   static void setUser(UserModel user) {
//     _user = user;
//   }

//   static UserModel? get user => _user;

//   static void clear() {
//     _user = null;
//   }

//   static bool get isLoggedIn => _user != null;
// }

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../../models/user_model.dart';

class UserService {
  static const String baseUrl = 'https://wisdom-walk-app.onrender.com/api';
  static final LocalStorageService _localStorageService = LocalStorageService();

  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(
        '$baseUrl/users/search?q=${Uri.encodeComponent(query)}',
      );
      debugPrint('Search Request: $url');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Search Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return (responseData['data'] as List)
              .map((userJson) => UserModel.fromJson(userJson))
              .toList();
        }
      }
      throw Exception('Failed to search users');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('Search error: $e');
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  static Future<UserModel> getCurrentUser() async {
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required - No token available');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/users/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Get Current User Response: ${response.statusCode}');
      _validateResponse(response);

      final responseData = json.decode(response.body);
      final user = UserModel.fromJson(responseData['data']);
      debugPrint('Fetched user avatarUrl: ${user.avatarUrl}');
      CurrentUser.setUser(user);
      return user;
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      debugPrint('Get current user error: $e');
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  static Future<UserModel> getUserById(String userId) async {
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required - No token available');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Get User by ID Response: ${response.statusCode}');
      _validateResponse(response);

      final responseData = json.decode(response.body);
      final user = UserModel.fromJson(responseData['data']);
      debugPrint('Fetched user avatarUrl: ${user.avatarUrl}');
      return user;
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  static Future<List<UserModel>> getRecentUsers() async {
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required - No token available');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/users/users/recents'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Get Recent Users Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final users =
            (responseData['data'] as List)
                .map((userJson) => UserModel.fromJson(userJson))
                .toList();
        debugPrint('Fetched ${users.length} recent users');
        return users;
      }
      return [];
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      debugPrint('Get recent users error: $e');
      return [];
    }
  }

  static void _validateResponse(http.Response response) {
    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ??
            'Request failed with status ${response.statusCode}',
      );
    }
  }
}

class CurrentUser {
  static UserModel? _user;

  static void setUser(UserModel user) {
    _user = user;
  }

  static UserModel? get user => _user;

  static void clear() {
    _user = null;
  }

  static bool get isLoggedIn => _user != null;
}
