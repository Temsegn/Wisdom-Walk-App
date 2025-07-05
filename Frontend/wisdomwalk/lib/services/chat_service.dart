import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final LocalStorageService _localStorageService = LocalStorageService();
  static const String baseUrl = 'https://wisdom-walk-app.onrender.com/api';

  Future<List<Chat>> getUserChats({int page = 1, int limit = 20}) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/chats?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => Chat.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load chats');
      }
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  Future<Chat> createDirectChat(String participantId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chats/direct'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
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
      throw Exception('Failed to create chat: ${response.statusCode}');
    }
  }

  Future<List<Message>> getChatMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/chats/$chatId/messages?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => Message.fromJson({...json, 'chatId': chatId}))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load messages');
      }
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  Future<Message> sendMessage({
    required String chatId,
    required String content,
    String? messageType,
    List<Map<String, dynamic>>? attachments,
    String? replyTo,
  }) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': content,
        'messageType': messageType ?? 'text',
        'attachments': attachments,
        'replyTo': replyTo,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Message.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to send message');
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/chats/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to delete message: ${response.statusCode}',
      );
    }
  }

  Future<Message> editMessage({
    required String messageId,
    required String content,
    String? encryptedContent,
  }) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl/chats/messages/$messageId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': content,
        'encryptedContent': encryptedContent,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Message.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to edit message');
      }
    } else {
      throw Exception('Failed to edit message: ${response.statusCode}');
    }
  }

  Future<void> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chats/messages/$messageId/reaction'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'emoji': emoji}),
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to add reaction: ${response.statusCode}',
      );
    }
  }

  Future<void> pinMessage(String chatId, String messageId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/pin/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to pin message: ${response.statusCode}',
      );
    }
  }

  Future<void> unpinMessage(String chatId, String messageId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.put(
      Uri.parse('$baseUrl/chats/$chatId/unpin/$messageId'), // Fixed typo
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to unpin message: ${response.statusCode}',
      );
    }
  }

  Future<void> muteChat(String chatId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/mute'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to mute chat: ${response.statusCode}',
      );
    }
  }

  Future<void> unmuteChat(String chatId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/unmute'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to unmute chat: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteChat(String chatId) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
        data['message'] ?? 'Failed to delete chat: ${response.statusCode}',
      );
    }
  }

  Future<List<Message>> searchMessages(String chatId, String query) async {
    final token = await _localStorageService.getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/chats/$chatId/messages/search?query=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => Message.fromJson({...json, 'chatId': chatId}))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to search messages');
      }
    } else {
      throw Exception('Failed to search messages: ${response.statusCode}');
    }
  }
}
