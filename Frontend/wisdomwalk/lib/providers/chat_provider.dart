import 'dart:async';
import 'dart:convert';

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
 

Future<Chat?> createDirectChatWithGreeting(String participantId, {String greeting = "👋 Hi!"}) async {
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
    // 1. Get authentication token from local storage
    final token = await LocalStorageService().getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    // 2. Prepare headers with authorization
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 3. Make the API request
    final response = await http.get(
      Uri.parse('https://wisdom-walk-app.onrender.com/api/chats/exists/$userId'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));

    // 4. Handle response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        if (data['exists'] == true) {
          return Chat.fromJson(data['chat']);
        }
        return null; // Chat doesn't exist
      }
      throw Exception(data['message'] ?? 'Failed to check chat existence');
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      await LocalStorageService().clearAuthToken();
      throw Exception('Session expired. Please login again.');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to check chat existence');
    }
  } on TimeoutException {
    throw Exception('Request timed out');
  } catch (e) {
    debugPrint('Error checking existing chat: $e');
    rethrow;
  }
}

Future<Chat?> startChatWithUser(UserModel user) async {
  try {
    // First check if chat already exists
    final existingChat = await getExistingChat(user.id);
    if (existingChat != null) {
      // Check if chat exists in local list
      final localIndex = _chats.indexWhere((c) => c.id == existingChat.id);
      if (localIndex == -1) {
        _chats.insert(0, existingChat);
        notifyListeners();
      }
      return existingChat;
    }

    // Show different greetings based on time of day
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = "🌅 Good morning!";
    } else if (hour < 17) {
      greeting = "☀️ Good afternoon!";
    } else {
      greeting = "🌙 Good evening!";
    }

    // Create new chat with greeting
    final newChat = await createDirectChatWithGreeting(user.id, greeting: greeting);
    
    if (newChat != null) {
      // Add to the beginning of the list
      _chats.insert(0, newChat);
      notifyListeners();
    }
    
    return newChat;
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    return null;
  }
}
}

