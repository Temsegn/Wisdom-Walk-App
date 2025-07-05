import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wisdomwalk/models/message_model.dart';
import 'package:wisdomwalk/providers/message_provider.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SocketService {
  IO.Socket? _socket;
  final BuildContext context;

  SocketService(this.context);

  void connect(String token) {
    _socket = IO.io('https://wisdom-walk-app.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    _socket?.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket?.on('newMessage', (data) {
      final message = Message.fromJson(data);
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).addNewMessage(message.chatId, message);
      Provider.of<ChatProvider>(
        context,
        listen: false,
      ).updateChatLastMessage(message.chatId, message);
    });

    _socket?.on('messageEdited', (data) {
      final message = Message.fromJson(data);
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).editMessage(message.id, message.content);
    });

    _socket?.on('messageDeleted', (data) {
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).deleteMessage(data['messageId']);
    });

    _socket?.on('messageReaction', (data) {
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).addReaction(data['messageId'], data['reactions']);
    });

    _socket?.on('messagePinned', (data) {
      // Update pinned status
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).pinMessage(data['chatId'], data['messageId']);
    });

    _socket?.on('messageUnpinned', (data) {
      // Update unpinned status
      // Add logic to update message pin status
    });

    _socket?.connect();
  }

  void joinChat(String chatId) {
    _socket?.emit('joinChat', chatId);
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
