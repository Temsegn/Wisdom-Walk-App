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

  SocketService(this.context);

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
      _startPingTimer();
      
      // Auto-join current chat if available
      if (_currentChatId != null) {
        joinChat(_currentChatId!);
      }
    });

    _socket?.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket disconnected - attempting reconnect');
      _cancelPingTimer();
      Future.delayed(const Duration(seconds: 2), () {
        if (_socket != null) {
          _socket?.connect();
        }
      });
    });

    _socket?.on('pong', (_) {
      debugPrint('Socket connection alive');
    });

    // Message event handlers
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

        // Avoid adding duplicate messages
        if (!messageProvider
            .getChatMessages(message.chatId)
            .any((m) => m.id == message.id)) {
          messageProvider.addNewMessage(message.chatId, message);
          chatProvider.updateChatLastMessage(message.chatId, message);
        }
      } catch (e) {
        debugPrint('Error handling newMessage: $e');
      }
    });

    _socket?.on('messageEdited', (data) {
      try {
        final message = Message.fromJson(data);
        if (!mounted) return;
        
        Provider.of<MessageProvider>(
          context,
          listen: false,
        ).editMessage(message.id, message.content);
      } catch (e) {
        debugPrint('Error handling messageEdited: $e');
      }
    });

    _socket?.on('messageDeleted', (data) {
      try {
        if (!mounted) return;
        
        Provider.of<MessageProvider>(
          context,
          listen: false,
        ).deleteMessage(data['messageId']);
      } catch (e) {
        debugPrint('Error handling messageDeleted: $e');
      }
    });

    _socket?.on('messageReaction', (data) {
      try {
        if (!mounted) return;
        
        final messageId = data['messageId'];
        final chatId = data['chatId'];
        final reaction = MessageReaction.fromJson(data['reaction']);
        
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        
        messageProvider.updateMessageReaction(chatId, messageId, reaction);
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
        
        messageProvider.updateMessagePinStatus(chatId, messageId, true);
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
        
        messageProvider.updateMessagePinStatus(chatId, messageId, false);
      } catch (e) {
        debugPrint('Error handling messageUnpinned: $e');
      }
    });

    // Typing indicators
    _socket?.on('typing', (data) {
      try {
        if (!mounted) return;
        debugPrint('User ${data['firstName']} is typing...');
        // Handle typing indicator UI updates
      } catch (e) {
        debugPrint('Error handling typing: $e');
      }
    });

    _socket?.on('stopTyping', (data) {
      try {
        if (!mounted) return;
        debugPrint('User stopped typing');
        // Handle stop typing indicator UI updates
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

  void joinChat(String chatId) {
    _currentChatId = chatId;
    if (_socket?.connected == true) {
      _socket?.emit('joinChat', chatId);
      debugPrint('Joined chat: $chatId');
    }
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

  void emitMessageEdited(String chatId, Message updatedMessage) {
    if (_socket?.connected == true) {
      _socket?.emit('messageEdited', {
        'chatId': chatId,
        'messageId': updatedMessage.id,
        'content': updatedMessage.content,
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
    debugPrint('Socket disconnected');
  }
}
