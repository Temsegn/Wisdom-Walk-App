import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

class ApiService {
  static const String baseUrl ='https://wisdom-walk-app.onrender.com/api';
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
  final LocalStorageService _localStorageService = LocalStorageService();

  Future<List<Chat>> getUserChats({int page = 1, int limit = 20}) async {
    try {
      // Get the authentication token
      final token = await _localStorageService.getAuthToken();
      
      // Debug prints
      print('DEBUG: Fetching user chats...');
      print('DEBUG: Using token: ${token != null ? '${token.substring(0, 5)}...' : 'NULL'}');

      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated - No token available');
      }

      final url = Uri.parse('$baseUrl/chats?page=$page&limit=$limit');
      print('DEBUG: Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timed out');
      });

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final chats = (responseData['data'] as List)
              .map((chatJson) => Chat.fromJson(chatJson))
              .toList();
          print('DEBUG: Successfully loaded ${chats.length} chats');
          return chats;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load chats');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - please login again');
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Invalid server response format');
    } catch (e) {
      print('ERROR in getUserChats: $e');
      throw Exception('Failed to load chats: ${e.toString()}');
    }
  }

static Future<Chat> createDirectChat(String participantId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/direct'),
        headers: _headers,
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

  static Future<List<Message>> getChatMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId/messages?page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final messages = (data['data'] as List)
              .map((messageJson) => Message.fromJson(messageJson))
              .toList();
          return messages;
        } else {
          throw Exception(data['message'] ?? 'Failed to load messages');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  static Future<Message> sendMessage({
    required String chatId,
    required String content,
    String messageType = 'text',
    String? replyToId,
    List<File>? attachments,
    Map<String, String>? scripture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/$chatId/messages'),
      );

      // Add headers
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add fields
      request.fields['content'] = content;
      request.fields['messageType'] = messageType;
      if (replyToId != null) {
        request.fields['replyToId'] = replyToId;
      }
      if (scripture != null) {
        request.fields['scripture'] = json.encode(scripture);
      }

      // Add files
      if (attachments != null) {
        for (var file in attachments) {
          request.files.add(await http.MultipartFile.fromPath(
            'attachments',
            file.path,
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Message.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to send message');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  static Future<Message> editMessage(
    String messageId,
    String content,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chat/messages/$messageId'),
        headers: _headers,
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

  static Future<void> deleteMessage(String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat/messages/$messageId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  static Future<void> addReaction(String messageId, String emoji) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages/$messageId/reaction'),
        headers: _headers,
        body: json.encode({'emoji': emoji}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add reaction');
      }
    } catch (e) {
      throw Exception('Error adding reaction: $e');
    }
  }

  static Future<void> pinMessage(String chatId, String messageId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$chatId/pin/$messageId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to pin message');
      }
    } catch (e) {
      throw Exception('Error pinning message: $e');
    }
  }

  static Future<void> unpinMessage(String chatId, String messageId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chat/$chatId/unpin/$messageId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unpin message');
      }
    } catch (e) {
      throw Exception('Error unpinning message: $e');
    }
  }

  static Future<Message> forwardMessage(
    String messageId,
    String targetChatId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages/$messageId/forward'),
        headers: _headers,
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

  static Future<void> muteChat(String chatId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$chatId/mute'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mute chat');
      }
    } catch (e) {
      throw Exception('Error muting chat: $e');
    }
  }

  static Future<void> unmuteChat(String chatId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$chatId/unmute'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unmute chat');
      }
    } catch (e) {
      throw Exception('Error unmuting chat: $e');
    }
  }

  static Future<List<Message>> searchMessages(
    String chatId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId/messages/search?query=$query&page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = (data['data'] as List)
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
        return messages;
      } else {
        throw Exception('Failed to search messages');
      }
    } catch (e) {
      throw Exception('Error searching messages: $e');
    }
  }
}
