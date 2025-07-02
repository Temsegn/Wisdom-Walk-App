import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class ChatProvider with ChangeNotifier {
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
    if (refresh) {
      _currentPage = 1;
      _chats.clear();
      _hasMoreChats = true;
    }

    if (_isLoading || !_hasMoreChats) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newChats = await ApiService.getUserChats(
        page: _currentPage,
        limit: 20,
      );

      if (newChats.isEmpty) {
        _hasMoreChats = false;
      } else {
        if (refresh) {
          _chats = newChats;
        } else {
          _chats.addAll(newChats);
        }
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Chat?> createDirectChat(String participantId) async {
    try {
      final chat = await ApiService.createDirectChat(participantId);
      
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
      final chat = await ApiService.createDirectChat(participantId);
      
      // Check if this is a new chat by trying to get messages
      try {
        final messages = await ApiService.getChatMessages(chat.id, limit: 1);
        
        // If no messages exist, send a greeting message
        if (messages.isEmpty) {
          await ApiService.sendMessage(
            chatId: chat.id,
            content: greeting,
            messageType: 'text',
          );
        }
      } catch (e) {
        // If we can't check messages, still send greeting
        await ApiService.sendMessage(
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

  Future<Chat?> startChatWithUser(UserModel user) async {
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

    return await createDirectChatWithGreeting(user.id, greeting: greeting);
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
}
