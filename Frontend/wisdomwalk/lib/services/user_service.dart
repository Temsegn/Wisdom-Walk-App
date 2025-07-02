import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';

class UserService {
  static const String baseUrl = 'https://your-api-url.com/api';
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final users = (data['data'] as List)
              .map((userJson) => UserModel.fromJson(userJson))
              .toList();
          return users;
        } else {
          throw Exception(data['message'] ?? 'Failed to search users');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to search users');
      }
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  static Future<UserModel> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = UserModel.fromJson(data['data']);
          CurrentUser.setUser(user);
          return user;
        } else {
          throw Exception(data['message'] ?? 'Failed to get user info');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to get user info');
      }
    } catch (e) {
      throw Exception('Error getting user info: $e');
    }
  }

  static Future<UserModel> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return UserModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get user');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to get user');
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  static Future<List<UserModel>> getRecentUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/recent'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final users = (data['data'] as List)
              .map((userJson) => UserModel.fromJson(userJson))
              .toList();
          return users;
        } else {
          throw Exception(data['message'] ?? 'Failed to get recent users');
        }
      } else {
        return []; // Return empty list if endpoint doesn't exist
      }
    } catch (e) {
      return []; // Return empty list on error
    }
  }
}
