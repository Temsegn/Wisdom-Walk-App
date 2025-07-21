import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wisdomwalk/models/message_model.dart';
import 'package:wisdomwalk/providers/message_provider.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class SocketService {
  IO.Socket? _socket;
  final BuildContext context;
  Timer? _pingTimer;
  String? _currentChatId;
  bool _isConnected = false;

  SocketService(this.context);

  bool get isConnected => _isConnected;

  void connect(String token) {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    
    _cancelPingTimer();

    _socket = IO.io('https://wisdom-walk-app.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token}, // Fixed: Move token to auth object
    });

    _socket?.onConnect((_) {
      debugPrint('Socket connected successfully');
      _isConnected = true;
      _startPingTimer();
      
      // Auto-join current chat if available
      if (_currentChatId != null) {
        _joinChatRoom(_currentChatId!);
      }
    });

    _socket?.onConnectError((data) {
      debugPrint('Socket connection error: $data');
      _isConnected = false;
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket disconnected - attempting reconnect');
      _isConnected = false;
      _cancelPingTimer();
      Future.delayed(const Duration(seconds: 2), () {
        if (_socket != null && !_isConnected) {
          _socket?.connect();
        }
      });
    });

    _socket?.on('pong', (_) {
      debugPrint('Socket connection alive');
    });

    // Setup message event handlers
    _setupMessageHandlers();

    _socket?.connect();
  }

  void _setupMessageHandlers() {
    _socket?.on('newMessage', (data) {
      try {
        final message = Message.fromJson(data);
        if (!mounted) return;
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);

        // Use the new handler method
        messageProvider.handleNewMessage(message);
        chatProvider.updateChatLastMessage(message.chatId, message);
      } catch (e) {
        debugPrint('Error handling newMessage: $e');
      }
    });

    _socket?.on('messageEdited', (data) {
      try {
        if (!mounted) return;
        
        final messageId = data['messageId'] ?? data['_id'];
        final content = data['content'];
        final chatId = data['chatId'] ?? data['chat'];
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.updateMessageEditStatus(chatId, messageId, content);
      } catch (e) {
        debugPrint('Error handling messageEdited: $e');
      }
    });

    _socket?.on('messageDeleted', (data) {
      try {
        if (!mounted) return;
        
        final messageId = data['messageId'];
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.handleMessageDeleted(messageId);
      } catch (e) {
        debugPrint('Error handling messageDeleted: $e');
      }
    });

    _socket?.on('messageReaction', (data) {
      try {
        if (!mounted) return;
        
        final messageId = data['messageId'];
        final chatId = data['chatId'];
        final reactionData = data['reaction'];
        
        final reaction = MessageReaction(
          emoji: reactionData['emoji'],
          userId: reactionData['userId'], // Fixed: use userId instead of user
          createdAt: DateTime.now(),
        );
        
        final isAdding = reactionData['isAdding'] ?? true;
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.handleMessageReaction(chatId, messageId, reaction, isAdding);
      } catch (e) {
        debugPrint('Error handling messageReaction: $e');
      }
    });

    _socket?.on('messagePinned', (data) {
      try {
        if (!mounted) return;
        
        final messageId = data['messageId'];
        final chatId = data['chatId'];
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.handleMessagePinned(chatId, messageId);
      } catch (e) {
        debugPrint('Error handling messagePinned: $e');
      }
    });

    _socket?.on('messageUnpinned', (data) {
      try {
        if (!mounted) return;
        
        final messageId = data['messageId'];
        final chatId = data['chatId'];
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.handleMessageUnpinned(chatId, messageId);
      } catch (e) {
        debugPrint('Error handling messageUnpinned: $e');
      }
    });

    // Typing indicators
    _socket?.on('typing', (data) {
      try {
        if (!mounted) return;
        final userId = data['userId'];
        final chatId = data['chatId'];
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.handleTypingIndicator(chatId, userId, true);
      } catch (e) {
        debugPrint('Error handling typing: $e');
      }
    });

    _socket?.on('stopTyping', (data) {
      try {
        if (!mounted) return;
        final userId = data['userId'];
        final chatId = data['chatId'];
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.handleTypingIndicator(chatId, userId, false);
      } catch (e) {
        debugPrint('Error handling stopTyping: $e');
      }
    });
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (timer) {
      if (_socket?.connected == true) {
        _socket?.emit('ping');
      }
    });
  }

  void _cancelPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  bool get mounted {
    try {
      return context.mounted;
    } catch (e) {
      return false;
    }
  }

  void _joinChatRoom(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('joinChat', chatId);
      debugPrint('Joined chat room: $chatId');
    }
  }

  void joinChat(String chatId) {
    _currentChatId = chatId;
    if (_isConnected) {
      _joinChatRoom(chatId);
    }
    // If not connected, it will auto-join when connection is established
  }

  void leaveChat(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('leaveChat', chatId);
      debugPrint('Left chat: $chatId');
    }
    if (_currentChatId == chatId) {
      _currentChatId = null;
    }
  }

  void sendTyping(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('typing', {'chatId': chatId});
    }
  }

  void stopTyping(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('stopTyping', {'chatId': chatId});
    }
  }

  void emitMessageDeleted(String chatId, String messageId) {
    if (_socket?.connected == true) {
      _socket?.emit('messageDeleted', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  void emitMessageEdited(String chatId, String messageId, String content) {
    if (_socket?.connected == true) {
      _socket?.emit('messageEdited', {
        'chatId': chatId,
        'messageId': messageId,
        'content': content,
      });
    }
  }

  void pinMessage(String chatId, String messageId) {
    if (_socket?.connected == true) {
      _socket?.emit('pinMessage', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  void unpinMessage(String chatId, String messageId) {
    if (_socket?.connected == true) {
      _socket?.emit('unpinMessage', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  void addReaction(String chatId, String messageId, String emoji) {
    if (_socket?.connected == true) {
      _socket?.emit('addReaction', {
        'chatId': chatId,
        'messageId': messageId,
        'emoji': emoji,
      });
    }
  }

  void disconnect() {
    _cancelPingTimer();
    _socket?.disconnect();
    _socket = null;
    _currentChatId = null;
    _isConnected = false;
    debugPrint('Socket disconnected');
  }
}
