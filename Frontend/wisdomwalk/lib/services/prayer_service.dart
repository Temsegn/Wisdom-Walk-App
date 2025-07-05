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
    final endpoint =
        '/posts?type="prayer"'; // at this place filter done
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
                (json['prayers'] as List<dynamic>?)
                    ?.map(
                      (prayer) =>
                          prayer['user'] is String
                              ? prayer['user'].toString()
                              : prayer['user']['_id']?.toString() ?? '',
                    )
                    .toList() ??
                [],
            'virtualHugUsers':
                (json['virtualHugs'] as List<dynamic>?)
                    ?.map(
                      (hug) =>
                          hug['user'] is String
                              ? hug['user'].toString()
                              : hug['user']['_id']?.toString() ?? '',
                    )
                    .toList() ??
                [],
            'likedUsers':
                (json['likes'] as List<dynamic>?)
                    ?.map(
                      (like) =>
                          like['user'] is String
                              ? like['user'].toString()
                              : like['user']['_id']?.toString() ?? '',
                    )
                    .toList() ??
                [],
            'reportCount': json['reportCount'] ?? 0,
            'isReported': json['isReported'] ?? false,
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
      'type': 'prayer',
      'content': content,
      'category': category,
      'isAnonymous': isAnonymous,
      'visibility': 'public',
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
          'virtualHugUsers': [],
          'likedUsers': [],
          'reportCount': 0,
          'isReported': false,
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

  Future<bool> togglePraying({
    required String prayerId,
    required String userId,
    String? message,
  }) async {
    print(
      'PrayerService.togglePraying called with prayerId=$prayerId, userId=$userId',
    );
    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/$prayerId/prayer',
      body: {'message': message ?? 'Praying for you ❤️'},
    );

    print('Toggle praying response status: ${response.statusCode}');
    print('Toggle praying response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return true;
      } else {
        throw Exception('${data['message']}: ${data['error']}');
      }
    } else {
      final data = jsonDecode(response.body);
      throw Exception('${data['message']}: ${data['error']}');
    }
  }

  Future<bool> toggleVirtualHug({
    required String prayerId,
    required String userId,
    String? scripture,
  }) async {
    print(
      'PrayerService.toggleVirtualHug called with prayerId=$prayerId, userId=$userId',
    );
    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/$prayerId/virtual-hug',
      body: scripture != null ? {'scripture': scripture} : {},
    );

    print('Toggle virtual hug response status: ${response.statusCode}');
    print('Toggle virtual hug response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return true;
      } else {
        throw Exception('${data['message']}: ${data['error']}');
      }
    } else {
      final data = jsonDecode(response.body);
      throw Exception('${data['message']}: ${data['error']}');
    }
  }

  Future<bool> toggleLike({
    required String prayerId,
    required String userId,
  }) async {
    print(
      'PrayerService.toggleLike called with prayerId=$prayerId, userId=$userId',
    );
    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/$prayerId/like',
      body: {},
    );

    print('Toggle like response status: ${response.statusCode}');
    print('Toggle like response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return true;
      } else {
        throw Exception('${data['message']}: ${data['error']}');
      }
    } else {
      final data = jsonDecode(response.body);
      throw Exception('${data['message']}: ${data['error']}');
    }
  }

  Future<bool> reportPost({
    required String prayerId,
    required String userId,
    required String reason,
    String type = 'inappropriate_content',
  }) async {
    print(
      'PrayerService.reportPost called with prayerId=$prayerId, userId=$userId, type=$type, reason=$reason',
    );
    final response = await _authenticatedRequest(
      method: 'POST',
      endpoint: '/$prayerId/report',
      body: {'type': type, 'reason': reason},
    );

    print('Report post response status: ${response.statusCode}');
    print('Report post response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return true;
      } else {
        throw Exception('${data['message']}: ${data['error']}');
      }
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      final errors = data['errors'] as List<dynamic>?;
      if (errors != null) {
        final reasonError = errors.firstWhere(
          (error) => error['path'] == 'reason',
          orElse: () => null,
        );
        if (reasonError != null) {
          throw Exception(
            reasonError['msg'] ??
                'Reason must be between 10 and 1000 characters',
          );
        }
        final typeError = errors.firstWhere(
          (error) => error['path'] == 'type',
          orElse: () => null,
        );
        if (typeError != null) {
          throw Exception(typeError['msg'] ?? 'Invalid report type');
        }
      }
      throw Exception(
        '${data['message']}: ${data['errors']?.map((e) => e['msg']).join(', ') ?? 'Validation failed'}',
      );
    } else {
      final data = jsonDecode(response.body);
      throw Exception('${data['message']}: ${data['error']}');
    }
  }

  Future<List<PrayerComment>> getComments(String prayerId) async {
    print('PrayerService.getComments called with prayerId=$prayerId');
    try {
      final response = await _authenticatedRequest(
        method: 'GET',
        endpoint: '/$prayerId/comments?page=1&limit=50', // Explicitly set limit
      );

      print('Get comments response status: ${response.statusCode}');
      print('Get comments response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');

        if (data['success'] == true) {
          final commentsData = data['data'] as List<dynamic>? ?? [];
          print('Comments data: $commentsData');
          return commentsData.map((json) {
            print('Processing comment JSON: $json');
            return PrayerComment.fromJson({
              'id': json['_id']?.toString() ?? '',
              'userId':
                  json['author'] is Map
                      ? json['author']['_id']?.toString() ??
                          json['author'].toString()
                      : json['author']?.toString() ?? '',
              'userName':
                  json['isAnonymous'] == true
                      ? null
                      : (json['author'] is Map
                          ? '${json['author']['firstName'] ?? ''} ${json['author']['lastName'] ?? ''}'
                              .trim()
                          : json['author']['firstName'] ?? 'Anonymous'),
              'userAvatar':
                  json['isAnonymous'] == true
                      ? null
                      : json['author'] is Map
                      ? json['author']['profilePicture']
                      : null,
              'content': json['content']?.toString() ?? '',
              'isAnonymous': json['isAnonymous'] ?? false,
              'createdAt':
                  json['createdAt']?.toString() ??
                  DateTime.now().toIso8601String(),
            });
          }).toList();
        } else {
          print('Error: success is false, message: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to fetch comments');
        }
      } else if (response.statusCode == 401) {
        print('PrayerService: Unauthorized - clearing token');
        await _localStorageService.clearAuthToken();
        throw Exception('Unauthorized: Please log in again');
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to fetch comments: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('PrayerService: Error fetching comments for prayer $prayerId: $e');
      rethrow; // Allow getPrayers to handle the error
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
      endpoint: '/$prayerId/comments',
      body: {'content': content, 'isAnonymous': isAnonymous},
    );

    print('Add comment response status: ${response.statusCode}');
    print('Add comment response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Parsed JSON data: $data'); // Debug the parsed structure
      final success = data['success'] as bool? ?? false;
      if (success) {
        final commentData = data['data'];
        return PrayerComment.fromJson({
          'id': commentData['_id'],
          'userId': commentData['author']['_id'] ?? commentData['author'],
          'userName':
              isAnonymous
                  ? null
                  : '${commentData['author']['firstName'] ?? ''} ${commentData['author']['lastName'] ?? ''}'
                      .trim(),
          'userAvatar':
              isAnonymous ? null : commentData['author']['profilePicture'],
          'content': commentData['content'],
          'isAnonymous': commentData['isAnonymous'] ?? false,
          'createdAt': commentData['createdAt'],
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
}
