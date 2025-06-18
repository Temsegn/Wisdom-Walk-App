import 'dart:async';
import '../models/chat_model.dart';

class ChatService {
  Future<List<ChatModel>> fetchChats() async {
    await Future.delayed(const Duration(seconds: 1));

    final chats = [
      ChatModel(
        id: '1',
        userId: 'user1',
        name: 'Afomia A.',
        status: 'Online',
        lastMessage: 'Hello sister! How are you doing today?',
        time: '10:30 PM',
        isOnline: true,
        unreadCount: 2,
        messages: [
          MessageModel(
            id: 'msg1',
            senderId: 'user1',
            content: 'Hello sister! How are you doing today?',
            time: '10:30 PM',
            isMe: false,
          ),
        ],
      ),
      ChatModel(
        id: '2',
        userId: 'user2',
        name: 'Rahel G.',
        status: '2 hours ago',
        lastMessage: 'Thank you for your prayers 🙏',
        time: '8:15 PM',
        isOnline: false,
        unreadCount: 0,
        messages: [
          MessageModel(
            id: 'msg2',
            senderId: 'user2',
            content: 'Thank you for your prayers 🙏',
            time: '8:15 PM',
            isMe: false,
          ),
        ],
      ),
    ];
    if (_isDebug) print('Fetched chats: ${chats.map((c) => c.id).toList()}');
    return chats;
  }

  Future<void> sendMessage(
    String chatId,
    String content,
    String currentUserId,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_isDebug) print('Sent message to $chatId: $content');
  }

  bool _isDebug = true; // Manual debug flag
}