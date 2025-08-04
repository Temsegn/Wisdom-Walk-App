import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/message_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class ChatProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreChats = true;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreChats => _hasMoreChats;

  Future<void> loadChats({bool refresh = false}) async {
    if (_isLoading || (!refresh && !_hasMoreChats)) return;

    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _hasMoreChats = true;
      _error = null;
    }
    notifyListeners();

    try {
      final newChats = await apiService.getUserChats(
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _chats = newChats;
      } else {
        _chats.addAll(newChats);
      }

      _hasMoreChats = newChats.length >= 20; // Assuming limit is 20
      if (_hasMoreChats) {
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error loading chats: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Chat?> createDirectChat(String participantId) async {
    try {
      final chat = await apiService.createDirectChat(participantId);

      // Add to the beginning of the list if it's new
      final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
      if (existingIndex == -1) {
        _chats.insert(0, chat);
        notifyListeners();
      }

      return chat;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Chat?> createDirectChatWithGreeting(
    String participantId, {
    String greeting = "👋 Hi!",
  }) async {
    try {
      // First create the chat
      final chat = await apiService.createDirectChat(participantId);

      // Check if this is a new chat by trying to get messages
      try {
        final messages = await apiService.getChatMessages(chat.id, limit: 1);

        // If no messages exist, send a greeting message
        if (messages.isEmpty) {
          await apiService.sendMessage(
            chatId: chat.id,
            content: greeting,
            messageType: 'text',
          );
        }
      } catch (e) {
        // If we can't check messages, still send greeting
        await apiService.sendMessage(
          chatId: chat.id,
          content: greeting,
          messageType: 'text',
        );
      }

      // Add to the beginning of the list if it's new
      final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
      if (existingIndex == -1) {
        _chats.insert(0, chat);
        notifyListeners();
      }

      return chat;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void updateChatLastMessage(String chatId, Message message) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];
      final updatedChat = Chat(
        id: chat.id,
        participants: chat.participants,
        type: chat.type,
        groupName: chat.groupName,
        groupDescription: chat.groupDescription,
        groupAdminId: chat.groupAdminId,
        lastMessageId: message.id,
        lastMessage: message,
        lastActivity: message.createdAt,
        isActive: chat.isActive,
        pinnedMessages: chat.pinnedMessages,
        participantSettings: chat.participantSettings,
        createdAt: chat.createdAt,
        updatedAt: DateTime.now(),
        unreadCount: chat.unreadCount + 1,
        chatName: chat.chatName,
        chatImage: chat.chatImage,
        isOnline: chat.isOnline,
      );

      _chats.removeAt(chatIndex);
      _chats.insert(0, updatedChat);
      notifyListeners();
    }
  }

  void markChatAsRead(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];
      final updatedChat = Chat(
        id: chat.id,
        participants: chat.participants,
        type: chat.type,
        groupName: chat.groupName,
        groupDescription: chat.groupDescription,
        groupAdminId: chat.groupAdminId,
        lastMessageId: chat.lastMessageId,
        lastMessage: chat.lastMessage,
        lastActivity: chat.lastActivity,
        isActive: chat.isActive,
        pinnedMessages: chat.pinnedMessages,
        participantSettings: chat.participantSettings,
        createdAt: chat.createdAt,
        updatedAt: chat.updatedAt,
        unreadCount: 0,
        chatName: chat.chatName,
        chatImage: chat.chatImage,
        isOnline: chat.isOnline,
      );

      _chats[chatIndex] = updatedChat;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Chat?> getExistingChat(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/chats/exists/$userId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['exists'] == true) {
          return Chat.fromJson(data['chat']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Existing chat check error: $e');
      return null;
    }
  }

  Future<Chat> startChatWithUser(UserModel user) async {
    try {
      // 1. Validate input
      if (user.id.isEmpty) {
        throw Exception('Invalid user ID');
      }

      // 2. Get auth token safely
      final token = await LocalStorageService().getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      // 3. Make request with better timeout
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/chats/direct'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'participantId': user.id,
              'participantName': user.fullName, // Additional data
            }),
          )
          .timeout(const Duration(seconds: 10));

      // 4. Parse response carefully
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Chat.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create chat');
      }
    } on TimeoutException {
      throw Exception('Server timeout. Try again later.');
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('Chat creation error: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await LocalStorageService().getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
