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

  SocketService(this.context);

  void connect(String token) {
   if (_socket != null) {
    _socket!.disconnect();
    _socket = null;
  }
    _socket = IO.io('https://wisdom-walk-app.onrender.com', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
    'extraHeaders': {'Authorization': 'Bearer $token'},
  });
   Timer.periodic(Duration(seconds: 25), (timer) {
    if (_socket?.connected == true) {
      _socket?.emit('ping'); 
    }
  });

  _socket?.on('pong', (_) {
    debugPrint('Socket connection alive');
  });

    _socket?.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket?.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });

    _socket!.onDisconnect((_) {
    debugPrint('Socket disconnected - attempting reconnect');
    Future.delayed(Duration(seconds: 2), () => _socket?.connect());
  });

    _socket?.on('newMessage', (data) {
      try {
        final message = Message.fromJson(data);
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
        final messageId = data['messageId'];
        final reaction = MessageReaction.fromJson(data['reaction']);
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        final messages = messageProvider.getChatMessages(data['chatId']);
        final messageIndex = messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          final updatedReactions = List<MessageReaction>.from(
            messages[messageIndex].reactions,
          )..add(reaction);
          // Update message with new reactions
          // Note: Message model needs to be immutable, so create a new instance
          final updatedMessage = Message(
            id: messages[messageIndex].id,
            chatId: messages[messageIndex].chatId,
            sender: messages[messageIndex].sender,
            content: messages[messageIndex].content,
            encryptedContent: messages[messageIndex].encryptedContent,
            messageType: messages[messageIndex].messageType,
            attachments: messages[messageIndex].attachments,
            scripture: messages[messageIndex].scripture,
            forwardedFromId: messages[messageIndex].forwardedFromId,
            isPinned: messages[messageIndex].isPinned,
            isEdited: messages[messageIndex].isEdited,
            editedAt: messages[messageIndex].editedAt,
            isDeleted: messages[messageIndex].isDeleted,
            deletedAt: messages[messageIndex].deletedAt,
            readBy: messages[messageIndex].readBy,
            reactions: updatedReactions,
            replyToId: messages[messageIndex].replyToId,
            replyTo: messages[messageIndex].replyTo,
            forwardedFrom: messages[messageIndex].forwardedFrom,
            createdAt: messages[messageIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          messages[messageIndex] = updatedMessage;
          messageProvider.notifyListeners();
        }
      } catch (e) {
        debugPrint('Error handling messageReaction: $e');
      }
    });

    _socket?.on('messagePinned', (data) {
      try {
        final messageId = data['messageId'];
        final chatId = data['chatId'];
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        final messages = messageProvider.getChatMessages(chatId);
        final messageIndex = messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          final updatedMessage = Message(
            id: messages[messageIndex].id,
            chatId: messages[messageIndex].chatId,
            sender: messages[messageIndex].sender,
            content: messages[messageIndex].content,
            encryptedContent: messages[messageIndex].encryptedContent,
            messageType: messages[messageIndex].messageType,
            attachments: messages[messageIndex].attachments,
            scripture: messages[messageIndex].scripture,
            forwardedFromId: messages[messageIndex].forwardedFromId,
            isPinned: true,
            isEdited: messages[messageIndex].isEdited,
            editedAt: messages[messageIndex].editedAt,
            isDeleted: messages[messageIndex].isDeleted,
            deletedAt: messages[messageIndex].deletedAt,
            readBy: messages[messageIndex].readBy,
            reactions: messages[messageIndex].reactions,
            replyToId: messages[messageIndex].replyToId,
            replyTo: messages[messageIndex].replyTo,
            forwardedFrom: messages[messageIndex].forwardedFrom,
            createdAt: messages[messageIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          messages[messageIndex] = updatedMessage;
          messageProvider.notifyListeners();
        }
      } catch (e) {
        debugPrint('Error handling messagePinned: $e');
      }
    });

    _socket?.on('messageUnpinned', (data) {
      try {
        final messageId = data['messageId'];
        final chatId = data['chatId'];
        final messageProvider = Provider.of<MessageProvider>(
          context,
          listen: false,
        );
        final messages = messageProvider.getChatMessages(chatId);
        final messageIndex = messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          final updatedMessage = Message(
            id: messages[messageIndex].id,
            chatId: messages[messageIndex].chatId,
            sender: messages[messageIndex].sender,
            content: messages[messageIndex].content,
            encryptedContent: messages[messageIndex].encryptedContent,
            messageType: messages[messageIndex].messageType,
            attachments: messages[messageIndex].attachments,
            scripture: messages[messageIndex].scripture,
            forwardedFromId: messages[messageIndex].forwardedFromId,
            isPinned: false,
            isEdited: messages[messageIndex].isEdited,
            editedAt: messages[messageIndex].editedAt,
            isDeleted: messages[messageIndex].isDeleted,
            deletedAt: messages[messageIndex].deletedAt,
            readBy: messages[messageIndex].readBy,
            reactions: messages[messageIndex].reactions,
            replyToId: messages[messageIndex].replyToId,
            replyTo: messages[messageIndex].replyTo,
            forwardedFrom: messages[messageIndex].forwardedFrom,
            createdAt: messages[messageIndex].createdAt,
            updatedAt: DateTime.now(),
          );
          messages[messageIndex] = updatedMessage;
          messageProvider.notifyListeners();
        }
      } catch (e) {
        debugPrint('Error handling messageUnpinned: $e');
      }
    });

    _socket?.connect();
  }

  void joinChat(String chatId) {
    if (_socket?.connected == true) {
      _socket?.emit('joinChat', chatId);
      debugPrint('Joined chat: $chatId');
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
      _socket?.emit('messageEdited', updatedMessage.toJson());
    }
  }
   
  void onMessagePinned(Function(dynamic) callback) {
    _socket?.on('message_pinned', callback);
  }

  void onMessageReacted(Function(dynamic) callback) {
    _socket?.on('message_reacted', callback);
  }

  void pinMessage(String chatId, String messageId) {
    _socket?.emit('pin_message', {
      'chatId': chatId,
      'messageId': messageId,
    });
  }

  void addReaction(String messageId, String emoji) {
    _socket?.emit('add_reaction', {
      'messageId': messageId,
      'emoji': emoji,
    });
  }


  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    debugPrint('Socket disconnected');
  }
}
