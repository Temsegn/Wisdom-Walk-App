import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../models/anonymous_share_model.dart';

class AnonymousShareService {
  static const String _baseUrl =
      'https://wisdom-walk-app.onrender.com/api/posts'; // Update with your backend URL

  final LocalStorageService _localStorageService = LocalStorageService();

  Future<List<AnonymousShareModel>> getAllAnonymousShares() async {
    print('AnonymousShareService: getAllAnonymousShares called');
    final response = await http.get(
      Uri.parse('$_baseUrl/posts?type="share"'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": 'Bearer ${await _localStorageService.getAuthToken()}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
        'AnonymousShareService: getAllAnonymousShares response: ${response.body}',
      );
      // Extract the shares list (adjust key based on API response)
      final List<dynamic> data =
          responseData['data'] ?? responseData['posts'] ?? [];
      return data.map((json) => AnonymousShareModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch shares: ${response.body}');
    }
  }

  Future<List<AnonymousShareModel>> getAnonymousShares({
    required AnonymousShareType type,
  }) async {
    print('AnonymousShareService: getAnonymousShares called with type: $type');
    // final backendType = _mapTypeToBackend(type);
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/posts?type="share"&category=${type.toString().split('.').last}&isAnonymous=true',
      ),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": 'Bearer ${await _localStorageService.getAuthToken()}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
        'AnonymousShareService: getAnonymousShares response: ${response.body}',
      );
      // Extract the shares list (adjust key based on API response)
      final List<dynamic> data =
          responseData['data'] ?? responseData['shares'] ?? [];
      return data.map((json) => AnonymousShareModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch shares: ${response.body}');
    }
  }

  Future<AnonymousShareModel> getAnonymousShareDetails(String shareId) async {
    print(
      'AnonymousShareService: getAnonymousShareDetails called for ID: $shareId',
    );
    final response = await http.get(
      Uri.parse('$_baseUrl/$shareId'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": 'Bearer ${await _localStorageService.getAuthToken()}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
        'AnonymousShareService: getAnonymousShareDetails response: ${response.body}',
      );
      // Extract the share object (adjust key based on API response)
      final Map<String, dynamic> data = responseData['data'] ?? responseData;
      return AnonymousShareModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch share details: ${response.body}');
    }
  }

  Future<AnonymousShareModel> addAnonymousShare({
    required String userId,
    required String content,
    required AnonymousShareType type,
    String? title,
    List<Map<String, String>> images = const [],
    required String token,
  }) async {
    print('AnonymousShareService: addAnonymousShare called with token: $token');
    final requestBody = {
      'author': userId,
      'content': content,
      'type': "share",
      'category': type.toString().split('.').last,
      'title': title,
      'images': images,
      'isAnonymous': true,
    };
    print(
      'AnonymousShareService: addAnonymousShare request body: ${jsonEncode(requestBody)}',
    );
    final response = await http.post(
      Uri.parse('$_baseUrl/postprayer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print(
        'AnonymousShareService: addAnonymousShare response: ${response.body}',
      );
      return AnonymousShareModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add share: ${response.body}');
    }
  }

  Future<void> updateHearts({
    required String shareId,
    required String userId,
    required String token,
  }) async {
    print('AnonymousShareService: updateHearts called with token: $token');
    final response = await http.post(
      Uri.parse('$_baseUrl/$shareId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle heart: ${response.body}');
    }
  }

  Future<void> updatePrayingUsers({
    required String shareId,
    required String userId,
    String? message,
    required String token,
  }) async {
    print(
      'AnonymousShareService: updatePrayingUsers called with token: $token',
    );
    final response = await http.post(
      Uri.parse('$_baseUrl/$shareId/prayer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'message': message ?? 'Praying for you ❤️',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle prayer: ${response.body}');
    }
  }

  Future<void> sendVirtualHug({
    required String shareId,
    required String userId,
    String? scripture,
    required String token,
  }) async {
    print('AnonymousShareService: sendVirtualHug called with token: $token');
    final response = await http.post(
      Uri.parse('$_baseUrl/$shareId/virtual-hug'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId, 'scripture': scripture ?? ''}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send virtual hug: ${response.body}');
    }
  }

  Future<AnonymousShareComment> addComment({
    required String shareId,
    required String userId,
    required String content,
    required String token,
  }) async {
    print('AnonymousShareService: addComment called with token: $token');
    final response = await http.post(
      Uri.parse('$_baseUrl/$shareId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'content': content,
        'userName': 'Anonymous Sister',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('AnonymousShareService: addComment response: ${response.body}');
      return AnonymousShareComment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  Future<List<AnonymousShareComment>> getPostComments(String shareId) async {
    print('AnonymousShareService: getPostComments called for ID: $shareId');
    final response = await http.get(
      Uri.parse('$_baseUrl/$shareId/comments?page=1&limit=50'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _localStorageService.getAuthToken()}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(
        'AnonymousShareService: getPostComments response: ${response.body}',
      );

      // Extract the comments list from the response (adjust the key based on your API)
      final List<dynamic> data =
          responseData['comments'] ?? responseData['data'] ?? [];

      return data.map((json) => AnonymousShareComment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch comments: ${response.body}');
    }
  }

  Future<void> reportShare({
    required String shareId,
    required String userId,
    required String reason,
    required String token,
  }) async {
    print('AnonymousShareService: reportShare called with token: $token');
    final response = await http.post(
      Uri.parse('$_baseUrl/$shareId/report'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': userId, 'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to report share: ${response.body}');
    }
  }
}
