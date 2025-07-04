import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../../models/user_model.dart';

class UserService {
  static const String baseUrl ='https://wisdom-walk-app.onrender.com/api';
  static String? _authToken;
  final LocalStorageService _localStorageService = LocalStorageService();

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
Future<List<UserModel>> searchUsers(String query) async {
  try {
    // Get the authentication token
      final token = await _localStorageService.getAuthToken();
    
    // Debug prints
    print('Searching users with query: $query');
    print('Using token: ${token != null ? '${token.substring(0, 5)}...' : 'NULL'}');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication required - No token available');
    }

    final url = Uri.parse('$baseUrl/users/search?q=${Uri.encodeComponent(query)}');
    print('Request URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseData = json.decode(response.body);
    
    if (response.statusCode == 200 && responseData['success'] == true) {
      final users = (responseData['data'] as List)
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
      print('Found ${users.length} users');
      return users;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to search users');
    }
  } on FormatException {
    throw Exception('Invalid server response format');
  } 
   catch (e) {
    print('Search error: $e');
    throw Exception('Failed to search users: ${e.toString()}');
  }
}
  static Future<UserModel> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
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
