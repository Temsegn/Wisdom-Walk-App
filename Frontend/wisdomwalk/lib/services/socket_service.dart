import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wisdomwalk/models/message_model.dart';
import 'package:wisdomwalk/providers/message_provider.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class SocketService {
  IO.Socket? _socket;
  final BuildContext context;
  bool _isConnected = false;
  final List<String> _joinedChats = [];

  SocketService(this.context);

  void connect(String token) {
    if (_socket != null && _isConnected) return;

    // Disconnect existing socket if any
    _socket?.disconnect();
    _socket = null;

    _socket = IO.io(
      'https://wisdom-walk-app.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _setupEventListeners();
    _socket?.connect();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      debugPrint('Socket connected');
      // Rejoin any chats that were joined before disconnection
      for (final chatId in _joinedChats) {
        joinChat(chatId);
      }
    });

    _socket?.onConnectError((data) {
      _isConnected = false;
      debugPrint('Socket connection error: $data');
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Socket disconnected');
    });

    _socket?.on('newMessage', (data) => _handleNewMessage(data));
    _socket?.on('messageEdited', (data) => _handleMessageEdited(data));
    _socket?.on('messageDeleted', (data) => _handleMessageDeleted(data));
    _socket?.on('messageReaction', (data) => _handleMessageReaction(data));
    _socket?.on('messagePinned', (data) => _handleMessagePinned(data));
    _socket?.on('messageUnpinned', (data) => _handleMessageUnpinned(data));
    _socket?.on('error', (data) => debugPrint('Socket error: $data'));
  }

  void _handleNewMessage(dynamic data) {
    try {
      final message = Message.fromJson(data);
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Check if message already exists
      if (!messageProvider.getChatMessages(message.chatId).any((m) => m.id == message.id)) {
        messageProvider.addNewMessage(message.chatId, message);
        chatProvider.updateChatLastMessage(message.chatId, message);
        
        // Scroll to bottom if this is the current chat
        if (message.chatId == ModalRoute.of(context)?.settings.arguments) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Trigger scroll to bottom in the chat screen
          });
        }
      }
    } catch (e) {
      debugPrint('Error handling newMessage: $e');
    }
  }

  void _handleMessageEdited(dynamic data) {
    try {
      final message = Message.fromJson(data);
      Provider.of<MessageProvider>(context, listen: false)
          .editMessage(message.id, message.content);
    } catch (e) {
      debugPrint('Error handling messageEdited: $e');
    }
  }

  void _handleMessageDeleted(dynamic data) {
    try {
      Provider.of<MessageProvider>(context, listen: false)
          .deleteMessage(data['messageId']);
    } catch (e) {
      debugPrint('Error handling messageDeleted: $e');
    }
  }

  void _handleMessageReaction(dynamic data) {
    try {
      final messageId = data['messageId'];
      final chatId = data['chatId'];
      final reaction = MessageReaction.fromJson(data['reaction']);
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      
      messageProvider.updateMessageReaction(chatId, messageId, reaction);
    } catch (e) {
      debugPrint('Error handling messageReaction: $e');
    }
  }

  void _handleMessagePinned(dynamic data) {
    try {
      final messageId = data['messageId'];
      final chatId = data['chatId'];
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      // Update message pinned status
      messageProvider.updateMessagePinnedStatus(chatId, messageId, true);
      
      // Update chat last message if needed
      final messages = messageProvider.getChatMessages(chatId);
      final message = messages.firstWhere((m) => m.id == messageId);
      chatProvider.updateChatLastMessage(chatId, message);
    } catch (e) {
      debugPrint('Error handling messagePinned: $e');
    }
  }

  void _handleMessageUnpinned(dynamic data) {
    try {
      final messageId = data['messageId'];
      final chatId = data['chatId'];
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      
      messageProvider.updateMessagePinnedStatus(chatId, messageId, false);
    } catch (e) {
      debugPrint('Error handling messageUnpinned: $e');
    }
  }

  void joinChat(String chatId) {
    if (_isConnected && !_joinedChats.contains(chatId)) {
      _socket?.emit('joinChat', chatId);
      _joinedChats.add(chatId);
      debugPrint('Joined chat: $chatId');
    }
  }

  void leaveChat(String chatId) {
    if (_isConnected && _joinedChats.contains(chatId)) {
      _socket?.emit('leaveChat', chatId);
      _joinedChats.remove(chatId);
      debugPrint('Left chat: $chatId');
    }
  }

  void emitMessageSent(Message message) {
    if (_isConnected) {
      _socket?.emit('sendMessage', message.toJson());
    }
  }

  void emitMessageEdited(Message message) {
    if (_isConnected) {
      _socket?.emit('editMessage', message.toJson());
    }
  }

  void emitMessageDeleted(String chatId, String messageId) {
    if (_isConnected) {
      _socket?.emit('deleteMessage', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  void emitMessageReaction(String chatId, String messageId, String emoji) {
    if (_isConnected) {
      _socket?.emit('addReaction', {
        'chatId': chatId,
        'messageId': messageId,
        'emoji': emoji,
      });
    }
  }

  void emitMessagePin(String chatId, String messageId) {
    if (_isConnected) {
      _socket?.emit('pinMessage', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  void emitMessageUnpin(String chatId, String messageId) {
    if (_isConnected) {
      _socket?.emit('unpinMessage', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _joinedChats.clear();
    debugPrint('Socket disconnected');
  }

  bool get isConnected => _isConnected;
}