import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wisdomwalk/utils/constants.dart';

class SocketProvider with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  IO.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

  void initSocket(String token) {
    try {
      _socket = IO.io(
        Constants.apiUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('Socket connected');
        _isConnected = true;
        notifyListeners();
      });

      _socket!.onDisconnect((_) {
        print('Socket disconnected');
        _isConnected = false;
        notifyListeners();
      });

      _socket!.onError((error) {
        print('Socket error: $error');
        _isConnected = false;
        notifyListeners();
      });
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  // Chat methods
  void joinChat(String chatId) {
    if (_isConnected) {
      _socket!.emit('chat:join', {'chatId': chatId});
    }
  }

  void leaveChat(String chatId) {
    if (_isConnected) {
      _socket!.emit('chat:leave', {'chatId': chatId});
    }
  }

  void sendMessage(String chatId, String message) {
    if (_isConnected) {
      _socket!.emit('chat:send_message', {
        'chatId': chatId,
        'content': message,
        'messageType': 'text',
      });
    }
  }

  void startTyping(String chatId) {
    if (_isConnected) {
      _socket!.emit('chat:typing', {'chatId': chatId});
    }
  }

  void stopTyping(String chatId) {
    if (_isConnected) {
      _socket!.emit('chat:stop_typing', {'chatId': chatId});
    }
  }

  void markMessagesRead(String chatId, String lastMessageId) {
    if (_isConnected) {
      _socket!.emit('chat:mark_read', {
        'chatId': chatId,
        'lastMessageId': lastMessageId,
      });
    }
  }

  // Group methods
  void joinGroupRoom(String groupType) {
    if (_isConnected) {
      _socket!.emit('group:join', {'groupType': groupType});
    }
  }

  void leaveGroupRoom(String groupType) {
    if (_isConnected) {
      _socket!.emit('group:leave', {'groupType': groupType});
    }
  }

  void joinGroupChat(String groupType, String chatId) {
    if (_isConnected) {
      _socket!.emit('group:join_chat', {
        'groupType': groupType,
        'chatId': chatId,
      });
    }
  }

  void leaveGroupChat(String groupType, String chatId) {
    if (_isConnected) {
      _socket!.emit('group:leave_chat', {
        'groupType': groupType,
        'chatId': chatId,
      });
    }
  }

  void sendGroupMessage(String groupType, String chatId, String message) {
    if (_isConnected) {
      _socket!.emit('group:send_message', {
        'groupType': groupType,
        'chatId': chatId,
        'content': message,
        'messageType': 'text',
      });
    }
  }

  void startGroupTyping(String groupType, String chatId) {
    if (_isConnected) {
      _socket!.emit('group:typing', {
        'groupType': groupType,
        'chatId': chatId,
      });
    }
  }

  void stopGroupTyping(String groupType, String chatId) {
    if (_isConnected) {
      _socket!.emit('group:stop_typing', {
        'groupType': groupType,
        'chatId': chatId,
      });
    }
  }

  void markGroupMessagesRead(String groupType, String chatId) {
    if (_isConnected) {
      _socket!.emit('group:mark_read', {
        'groupType': groupType,
        'chatId': chatId,
      });
    }
  }

  // Post methods
  void likePost(String postId) {
    if (_isConnected) {
      _socket!.emit('post:like', {'postId': postId});
    }
  }

  void unlikePost(String postId) {
    if (_isConnected) {
      _socket!.emit('post:unlike', {'postId': postId});
    }
  }

  void commentOnPost(String postId, String content) {
    if (_isConnected) {
      _socket!.emit('post:comment', {
        'postId': postId,
        'content': content,
      });
    }
  }

  void likeComment(String postId, String commentId) {
    if (_isConnected) {
      _socket!.emit('post:like_comment', {
        'postId': postId,
        'commentId': commentId,
      });
    }
  }

  void unlikeComment(String postId, String commentId) {
    if (_isConnected) {
      _socket!.emit('post:unlike_comment', {
        'postId': postId,
        'commentId': commentId,
      });
    }
  }
}
