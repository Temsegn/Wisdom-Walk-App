import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'dart:convert';

class PrayerService {
  static const String apiBaseUrl =
      'https://wisdom-walk-app.onrender.com/api/posts';
  final LocalStorageService _localStorageService;

  PrayerService({required LocalStorageService localStorageService})
    : _localStorageService = localStorageService;

  Future<http.Response> _authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final token = await _localStorageService.getAuthToken();
    print(
      'Making $method request to $apiBaseUrl$endpoint with token: ${token?.substring(0, 10)}...',
    );

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$apiBaseUrl$endpoint');
    print('Sending $method request to $uri with body: $body');

    try {
      if (method == 'GET') {
        return await http.get(uri, headers: headers);
      } else if (method == 'POST') {
        return await http.post(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'PUT') {
        return await http.put(uri, headers: headers, body: jsonEncode(body));
      }
      throw Exception('Unsupported HTTP method');
    } catch (e) {
      print('Network error in _authenticatedRequest: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<PrayerModel>> getPrayers({required String filter}) async {
    print('PrayerService.getPrayers called');
    final endpoint = '/posts';
    final response = await _authenticatedRequest(
      method: 'GET',
      endpoint: endpoint,
    );

    print('PrayerService: Get prayers response status: ${response.statusCode}');
    print('PrayerService: Get prayers response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Failed to fetch prayers');
      }
      final posts = data['data'] as List;
      print('PrayerService: Fetched ${posts.length} posts');

      final List<PrayerModel> prayers = [];
      for (var json in posts) {
        List<PrayerComment> comments = [];
        try {
          comments = await getComments(json['_id']);
          print(
            'PrayerService: Fetched ${comments.length} comments for post ${json['_id']}',
          );
        } catch (e) {
          print(
            'PrayerService: Failed to fetch comments for post ${json['_id']}: $e',
          );
        }
        prayers.add(
          PrayerModel.fromJson({
            'id': json['_id']?.toString() ?? '',
            'userId':
                json['author']['_id']?.toString() ??
                json['author']?.toString() ??
                '',
            'userName':
                json['isAnonymous']
                    ? null
                    : '${json['author']['firstName'] ?? ''} ${json['author']['lastName'] ?? ''}'
                        .trim(),
            'userAvatar':
                json['isAnonymous'] ? null : json['author']['profilePicture'],
            'content': json['content']?.toString() ?? '',
            'title': json['title'],
            'isAnonymous': json['isAnonymous'] ?? false,
            'prayingUsers':
                (json['prayers'] as List<dynamic>?)?.map((prayer) {
                  // Handle case where prayer['user'] is a string or an object
                  return prayer['user'] is String
                      ? prayer['user'].toString()
                      : prayer['user']['_id']?.toString() ?? '';
                }).toList() ??
                [],
            'comments': comments.map((comment) => comment.toJson()).toList(),
            'createdAt':
                json['createdAt']?.toString() ??
                DateTime.now().toIso8601String(),
          }),
        );
      }
      return prayers;
    } else if (response.statusCode == 401) {
      print('PrayerService: Unauthorized - clearing token');
      await _localStorageService.clearAuthToken();
      throw Exception('Unauthorized: Session expired. Please log in again.');
    } else {
      throw Exception(
        'Failed to fetch prayers: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PrayerModel> addPrayer({
    required String userId,
    required String content,
    required String category,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
    String? title,
  }) async {
    print(
      'PrayerService.addPrayer called with userId=$userId, content=$content, isAnonymous=$isAnonymous',
    );
    final body = {
      'type': 'prayer', // Hardcode to ensure correctness
      'content': content,
      'category': category, // Add category to the request body
      'isAnonymous': isAnonymous,
      'visibility': 'public', // Add if required
      if (title != null) 'title': title,
    };
    print('Request body: $body');

    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/postprayer',
      body: body,
    );

    print('Backend response status: ${response.statusCode}');
    print('Backend response body: ${response.body}');
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final post = data['data'];
        final author = post['author'];

        // Safe parsing
        final String userId =
            author is Map
                ? (author['_id']?.toString() ?? '')
                : author.toString();
        final String? userName =
            isAnonymous
                ? null
                : (author is Map
                    ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'
                        .trim()
                    : null);
        final String? userAvatar =
            isAnonymous
                ? null
                : (author is Map ? author['profilePicture'] : null);

        print('Prayer created successfully: ${post['_id']}');

        return PrayerModel.fromJson({
          'id': post['_id'],
          'userId': userId,
          'userName': userName,
          'userAvatar': userAvatar,
          'content': post['content'],
          'title': post['title'],
          'isAnonymous': post['isAnonymous'],
          'prayingUsers': [],
          'comments': [],
          'createdAt': post['createdAt'],
        });
      } else {
        throw Exception('${data['message']}: ${data['error']}');
      }
    } else if (response.statusCode == 401) {
      print('Unauthorized request - clearing token');
      await _localStorageService.clearAuthToken();
      throw Exception('Unauthorized: Please log in again');
    } else {
      final data = jsonDecode(response.body);
      throw Exception('${data['message']}: ${data['error']}');
    }
  }

  Future<void> updatePrayingUsers({
    required String prayerId,
    required List<String> prayingUsers,
  }) async {
    print('PrayerService.updatePrayingUsers called with prayerId=$prayerId');
    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/posts/$prayerId/prayer',
      body: {'message': 'Praying for you ❤️'},
    );

    print('Update praying users response status: ${response.statusCode}');
    print('Update praying users response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update praying status: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PrayerComment> addComment({
    required String prayerId,
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
    print(
      'PrayerService.addComment called with prayerId=$prayerId, content=$content',
    );
    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/posts/$prayerId/comments',
      body: {'content': content, 'isAnonymous': isAnonymous},
    );

    print('Add comment response status: ${response.statusCode}');
    print('Add comment response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return PrayerComment.fromJson({
          'id': data['data']['_id'],
          'userId': data['data']['author']['_id'] ?? data['data']['author'],
          'userName':
              isAnonymous
                  ? null
                  : '${data['data']['author']['firstName']} ${data['data']['author']['lastName']}',
          'userAvatar':
              isAnonymous ? null : data['data']['author']['profilePicture'],
          'content': data['data']['content'],
          'isAnonymous': data['data']['isAnonymous'],
          'createdAt': data['data']['createdAt'],
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to add comment');
      }
    } else {
      throw Exception(
        'Failed to add comment: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<PrayerComment>> getComments(String prayerId) async {
    print('PrayerService.getComments called with prayerId=$prayerId');
    final response = await _authenticatedRequest(
      method: 'GET',
      endpoint: '/posts/$prayerId/comments',
    );

    print('Get comments response status: ${response.statusCode}');
    print('Get comments response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map(
              (json) => PrayerComment.fromJson({
                'id': json['_id'],
                'userId': json['author']['_id'] ?? json['author'],
                'userName':
                    json['isAnonymous']
                        ? null
                        : '${json['author']['firstName']} ${json['author']['lastName']}',
                'userAvatar':
                    json['isAnonymous']
                        ? null
                        : json['author']['profilePicture'],
                'content': json['content'],
                'isAnonymous': json['isAnonymous'] ?? false,
                'createdAt': json['createdAt'],
              }),
            )
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch comments');
      }
    } else {
      throw Exception(
        'Failed to fetch comments: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
