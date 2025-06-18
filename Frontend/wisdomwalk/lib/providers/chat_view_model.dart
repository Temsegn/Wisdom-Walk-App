import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatViewModel with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatModel> _chats = [];
  ChatModel? _selectedChat;
  bool _isLoading = false;
  String? _userId; // Store the current user's ID

  List<ChatModel> get chats => _chats;
  ChatModel? get selectedChat => _selectedChat;
  bool get isLoading => _isLoading;
  String? get userId => _userId; // Getter for userId

  // Initialize with userId and fetch chats
  void initialize(String userId) {
    if (_userId == null) {
      _userId = userId;
      _fetchChats(); // Fetch chats immediately after setting userId
    }
  }

  Future<void> _fetchChats() async {
    if (_userId == null) {
      if (kDebugMode) print('Error: userId is not initialized');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _chats = await _chatService.fetchChats();
    } catch (e) {
      if (kDebugMode) print('Error fetching chats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectChat(String? chatId) {
    if (chatId == null) {
      _selectedChat = null;
    } else {
      _selectedChat = _chats.firstWhere(
        (chat) => chat.id == chatId,
        orElse: () => throw Exception('Chat not found'),
      );
      if (_selectedChat != null) {
        _selectedChat = _selectedChat!.copyWith(
          unreadCount: 0,
        ); // Reset unread count
      }
    }
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_selectedChat != null && _userId != null) {
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _userId!,
        content: content,
        time: _formatTime(DateTime.now()),
        isMe: true,
      );
      _selectedChat!.messages.add(newMessage);
      _selectedChat!.lastMessage = content;
      _selectedChat!.time = _formatTime(DateTime.now());

      notifyListeners();

      // Simulate sending to server
      await _chatService.sendMessage(_selectedChat!.id, content, _userId!);
    } else {
      if (kDebugMode) print('Error: No selected chat or userId');
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  // Helper method to create a copy with updated values
  ChatModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? status,
    String? lastMessage,
    String? time,
    bool? isOnline,
    int? unreadCount,
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      id: id ?? _selectedChat!.id,
      userId: userId ?? _selectedChat!.userId,
      name: name ?? _selectedChat!.name,
      status: status ?? _selectedChat!.status,
      lastMessage: lastMessage ?? _selectedChat!.lastMessage,
      time: time ?? _selectedChat!.time,
      isOnline: isOnline ?? _selectedChat!.isOnline,
      unreadCount: unreadCount ?? _selectedChat!.unreadCount,
      messages: messages ?? _selectedChat!.messages,
    );
  }
}
