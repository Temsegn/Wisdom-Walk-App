import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'dart:convert';

class AuthService {
  final LocalStorageService _localStorageService = LocalStorageService();

  static const String baseUrl = 'https://wisdom-walk-app.onrender.com/api/auth';

  void _handleError(http.Response response) {
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Request failed: ${response.statusCode}');
  }

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String city,
    required String country, // Removed subcity as it's unused
    required String idImagePath,
    required String faceImagePath,
    String? dateOfBirth,
    String? phoneNumber,
  }) async {
    print('Registering with baseUrl: $baseUrl'); // Debug log

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/register'));

    // Add form fields
    request.fields.addAll({
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'location[city]': city,
      'location[country]': country,
      'dateOfBirth': dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 18)).toIso8601String(),
      'phoneNumber': phoneNumber ?? '1234567890',
      'bio': '',
    });

    // Add image files from paths
    try {
      if (!File(idImagePath).existsSync() || !File(faceImagePath).existsSync()) {
        throw Exception('Invalid image file paths: idImagePath=$idImagePath, faceImagePath=$faceImagePath');
      }

      request.files.add(await http.MultipartFile.fromPath(
        'nationalId',
        idImagePath,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'livePhoto',
        faceImagePath,
        contentType: MediaType('image', 'jpeg'),
      ));

      print('Uploading images: nationalId=$idImagePath, livePhoto=$faceImagePath');
      print('Request fields: ${request.fields}'); // Debug all fields

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('Response status: ${response.statusCode}, body: ${responseBody.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody.body)['data'];
        return UserModel(
          id: data['userId'],
          fullName: '${data['firstName']} ${data['lastName']}'.trim(),
          email: data['email'],
          city: city,
          country: country,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      _handleError(responseBody);
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
    }

    throw Exception('Failed to complete registration');
  }

  // Login user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    print('Logging in with baseUrl: $baseUrl'); // Debug log
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      await _localStorageService.saveAuthToken(data['token']);
      return UserModel.fromJson({
        'id': data['user']['_id'],
        'fullName': '${data['user']['firstName']} ${data['user']['lastName']}'.trim(),
        'email': data['user']['email'],
        'avatarUrl': data['user']['profilePicture'],
        'city': data['user']['location']['city'],
        'country': data['user']['location']['country'],
        'wisdomCircleInterests': (data['user']['joinedGroups'] ?? []).map((g) => g['groupType']).toList(),
        'isVerified': (data['user']['isEmailVerified'] ?? false) && (data['user']['isAdminVerified'] ?? false),
        'createdAt': data['user']['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': data['user']['updatedAt'] ?? DateTime.now().toIso8601String(),
      });
    }
    _handleError(response);
    throw Exception('Failed to login');
  }

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': otp}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final emailVerified = body['data']?['emailVerified'] ?? false;
      return emailVerified == true;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to verify OTP');
    }
  }

  Future<void> resendOtp({required String email}) async {
    print('Resending OTP with baseUrl: $baseUrl'); // Debug log
    final response = await http.post(
      Uri.parse('$baseUrl/resend-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    print('Sending forgot password request with baseUrl: $baseUrl'); // Debug log
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    print('Resetting password with baseUrl: $baseUrl'); // Debug log
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': otp,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? city,
    String? country,
    String? avatarPath,
    List<String>? wisdomCircleInterests,
  }) async {
    print('Updating profile with baseUrl: $baseUrl'); // Debug log
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/profile'));

    // Add form fields
    request.fields.addAll({
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (city != null) 'location[city]': city,
      if (country != null) 'location[country]': country,
      if (wisdomCircleInterests != null)
        'joinedGroups': jsonEncode(wisdomCircleInterests.map((e) => {'groupType': e}).toList()),
    });

    // Add profile picture if provided
    if (avatarPath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        avatarPath,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    // Add authorization header
    final token = await _localStorageService.getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    } else {
      throw Exception('No auth token found');
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody.body)['data'];
      return UserModel.fromJson({
        'id': data['_id'],
        'fullName': '${data['firstName']} ${data['lastName']}'.trim(),
        'email': data['email'],
        'avatarUrl': data['profilePicture'],
        'city': data['location']['city'],
        'country': data['location']['country'],
        'wisdomCircleInterests': (data['joinedGroups'] ?? []).map((g) => g['groupType']).toList(),
        'isVerified': (data['isEmailVerified'] ?? false) && (data['isAdminVerified'] ?? false),
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
      });
    }
    _handleError(responseBody);
    throw Exception('Failed to update profile');
  }

  Future<UserModel> getCurrentUser() async {
    print('Getting current user with baseUrl: $baseUrl'); // Debug log
    final token = await _localStorageService.getAuthToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return UserModel.fromJson({
        'id': data['_id'],
        'fullName': '${data['firstName']} ${data['lastName']}'.trim(),
        'email': data['email'],
        'avatarUrl': data['profilePicture'],
        'city': data['location']['city'],
        'country': data['location']['country'],
        'wisdomCircleInterests': (data['joinedGroups'] ?? []).map((g) => g['groupType']).toList(),
        'isVerified': (data['isEmailVerified'] ?? false) && (data['isAdminVerified'] ?? false),
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
      });
    }
    _handleError(response);
    throw Exception('Failed to get current user');
  }

  Future<void> logout() async {
    print('Logging out with baseUrl: $baseUrl'); // Debug log
    final token = await _localStorageService.getAuthToken();
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    await _localStorageService.clearAuthToken();
  }
}