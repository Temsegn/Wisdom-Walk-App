import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

class ApiService {
  static const String baseUrl = 'https://wisdom-walk-app.onrender.com/api';
  static const Duration timeoutDuration = Duration(seconds: 30);

  final LocalStorageService _localStorageService = LocalStorageService();
  String? _authToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<String?> getAuthToken() async {
    try {
      _authToken = await _localStorageService.getAuthToken();
      return _authToken;
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  Future<List<Chat>> getUserChats({int page = 1, int limit = 20}) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse('$baseUrl/chats?page=$page&limit=$limit');
      debugPrint('Fetching chats from: $url');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeoutDuration);

      debugPrint('Chats response status: ${response.statusCode}');
      debugPrint('Chats response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return (responseData['data'] as List)
              .map((chatJson) => Chat.fromJson(chatJson))
              .toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load chats');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to load chats. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException catch (e) {
      throw Exception('Invalid server response format: ${e.message}');
    } catch (e) {
      debugPrint('Error in getUserChats: $e');
      throw Exception('Failed to load chats: ${e.toString()}');
    }
  }

  Future<Chat> createDirectChat(String participantId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/direct'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'participantId': participantId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Chat.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create chat');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to create chat');
      }
    } catch (e) {
      throw Exception('Error creating chat: $e');
    }
  }

  Future<List<Message>> getChatMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/chats/$chatId/messages?page=$page&limit=$limit',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));
      debugPrint('Raw API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List?)
                  ?.map((json) {
                    try {
                      return Message.fromJson(json);
                    } catch (e) {
                      debugPrint('Failed to parse message: $e');
                      return null;
                    }
                  })
                  .whereType<Message>()
                  .toList() ??
              [];
        } else {
          throw Exception(data['message'] ?? 'Failed to load messages');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to load messages (Status: ${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      debugPrint('Error in getChatMessages: $e');
      throw Exception('Failed to load messages: ${e.toString()}');
    }
  }

  Future<Message> sendMessage({
    required String chatId,
    required String content,
    String messageType = 'text',
    String? replyToId,
    List<Map<String, dynamic>>? attachments,
    Map<String, String>? scripture,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse(
        'https://wisdom-walk-app.onrender.com/api/chats/$chatId/messages',
      );

      debugPrint('Sending message to: $url');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'content': content,
              'messageType': messageType,
              if (replyToId != null) 'replyToId': replyToId,
              if (attachments != null) 'attachments': attachments,
              if (scripture != null) 'scripture': scripture,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Send message response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Message.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to send message');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to send message (Status: ${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Future<Message> editMessage(String messageId, String content) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/chats/messages/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Message.fromJson(data['data']);
      } else {
        throw Exception('Failed to edit message');
      }
    } catch (e) {
      throw Exception('Error editing message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/chats/messages/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/messages/$messageId/reaction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'emoji': emoji}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add reaction');
      }
    } catch (e) {
      throw Exception('Error adding reaction: $e');
    }
  }

  Future<void> pinMessage(String chatId, String messageId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chats/$chatId/pin/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to pin message');
      }
    } catch (e) {
      throw Exception('Error pinning message: $e');
    }
  }

  Future<void> unpinMessage(String chatId, String messageId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/chats/$chatId/unpin/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unpin message');
      }
    } catch (e) {
      throw Exception('Error unpinning message: $e');
    }
  }

  Future<Message> forwardMessage(String messageId, String targetChatId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages/$messageId/forward'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'targetChatId': targetChatId}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Message.fromJson(data['data']);
      } else {
        throw Exception('Failed to forward message');
      }
    } catch (e) {
      throw Exception('Error forwarding message: $e');
    }
  }

  Future<void> muteChat(String chatId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/$chatId/mute'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mute chat');
      }
    } catch (e) {
      throw Exception('Error muting chat: $e');
    }
  }

  Future<void> unmuteChat(String chatId) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/$chatId/unmute'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unmute chat');
      }
    } catch (e) {
      throw Exception('Error unmuting chat: $e');
    }
  }

  Future<List<Message>> searchMessages(
    String chatId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/chat/$chatId/messages/search?query=$query&page=$page&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
      } else {
        throw Exception('Failed to search messages');
      }
    } catch (e) {
      throw Exception('Error searching messages: $e');
    }
  }
}
