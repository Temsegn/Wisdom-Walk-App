import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService chatService;

  ChatProvider(this.chatService) {
    loadUserChats();
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  List<Message> _currentChatMessages = [];
  List<Message> get currentChatMessages => _currentChatMessages;

  Chat? _currentChat;
  Chat? get currentChat => _currentChat;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadUserChats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chats = await chatService.getUserChats();
    } catch (e) {
      _error = 'Failed to load chats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDirectChat(String participantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newChat = await chatService.createDirectChat(participantId);
      _chats.add(newChat);
      _currentChat = newChat;
      await loadChatMessages(newChat.id);
    } catch (e) {
      _error = 'Failed to create chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChatMessages(String chatId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentChatMessages = await chatService.getChatMessages(chatId);
    } catch (e) {
      _error = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrentChat(Chat chat) async {
    _currentChat = chat;
    await loadChatMessages(chat.id);
    notifyListeners();
  }

  Future<void> sendMessage(String content, {String? replyToId}) async {
    if (_currentChat == null) return;

    try {
      final message = await chatService.sendMessage(
        chatId: _currentChat!.id,
        content: content,
        replyTo: replyToId,
      );
      _currentChatMessages.add(message);
      await loadUserChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await chatService.deleteMessage(messageId);
      _currentChatMessages.removeWhere((m) => m.id == messageId);
      await loadUserChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final updatedMessage = await chatService.editMessage(
        messageId: messageId,
        content: newContent,
      );
      final index = _currentChatMessages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _currentChatMessages[index] = updatedMessage;
        await loadUserChats();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to edit message: $e';
      notifyListeners();
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    try {
      await chatService.addReaction(
        messageId: messageId,
        emoji: emoji,
      );
      if (_currentChat != null) {
        await loadChatMessages(_currentChat!.id);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add reaction: $e';
      notifyListeners();
    }
  }

  Future<void> pinMessage(String messageId) async {
    if (_currentChat == null) return;

    try {
      await chatService.pinMessage(_currentChat!.id, messageId);
      await loadChatMessages(_currentChat!.id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to pin message: $e';
      notifyListeners();
    }
  }

  Future<void> unpinMessage(String messageId) async {
    if (_currentChat == null) return;

    try {
      await chatService.unpinMessage(_currentChat!.id, messageId);
      await loadChatMessages(_currentChat!.id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to unpin message: $e';
      notifyListeners();
    }
  }

  Future<void> muteCurrentChat() async {
    if (_currentChat == null) return;

    try {
      await chatService.muteChat(_currentChat!.id);
      await loadUserChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mute chat: $e';
      notifyListeners();
    }
  }

  Future<void> unmuteCurrentChat() async {
    if (_currentChat == null) return;

    try {
      await chatService.unmuteChat(_currentChat!.id);
      await loadUserChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to unmute chat: $e';
      notifyListeners();
    }
  }

  Future<void> deleteChat() async {
    if (_currentChat == null) return;

    try {
      await chatService.deleteChat(_currentChat!.id);
      _chats.removeWhere((chat) => chat.id == _currentChat!.id);
      _currentChat = null;
      _currentChatMessages = [];
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete chat: $e';
      notifyListeners();
    }
  }

  // Start or get an existing direct chat with a user
  Future<Chat> startChatWithUser(UserModel user) async {
    try {
      final existingChat = _chats.firstWhere(
        (chat) =>
            chat.type == 'direct' &&
            chat.participants.length == 2 &&
            chat.participants.contains(user.id),
        orElse: () => Chat(
          id: '',
          participants: [],
          type: '',
          lastActivity: DateTime.now(),
          isActive: false,
          pinnedMessages: [],
          participantSettings: [],
        ),
      );

      if (existingChat.id.isNotEmpty) {
        _currentChat = existingChat;
        await loadChatMessages(existingChat.id);
        notifyListeners();
        return existingChat;
      }

      final newChat = await chatService.createDirectChat(user.id);
      _chats.add(newChat);
      _currentChat = newChat;
      await loadChatMessages(newChat.id);
      notifyListeners();
      return newChat;
    } catch (e) {
      _error = 'Failed to start chat: $e';
      notifyListeners();
      rethrow;
    }
  }
}
