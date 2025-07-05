import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  Map<String, List<Message>> _chatMessages = {};
  Map<String, bool> _loadingStates = {};
  Map<String, String?> _errors = {};
  Map<String, int> _currentPages = {};
  Map<String, bool> _hasMoreMessages = {};
  Message? _replyToMessage;

  List<Message> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  bool isLoading(String chatId) {
    return _loadingStates[chatId] ?? false;
  }

  String? getError(String chatId) {
    return _errors[chatId];
  }

  bool hasMoreMessages(String chatId) {
    return _hasMoreMessages[chatId] ?? true;
  }

  Message? get replyToMessage => _replyToMessage;

  void setReplyToMessage(Message? message) {
    _replyToMessage = message;
    notifyListeners();
  }

  Future<void> loadMessages(String chatId, {bool refresh = false}) async {
    if (refresh) {
      _currentPages[chatId] = 1;
      _chatMessages[chatId] = [];
      _hasMoreMessages[chatId] = true;
    }

    if (_loadingStates[chatId] == true || _hasMoreMessages[chatId] == false) {
      return;
    }

    _loadingStates[chatId] = true;
    _errors[chatId] = null;
    notifyListeners();

    try {
      final newMessages = await ApiService.getChatMessages(
        chatId,
        page: _currentPages[chatId] ?? 1,
        limit: 50,
      );

      if (newMessages.isEmpty) {
        _hasMoreMessages[chatId] = false;
      } else {
        if (refresh) {
          _chatMessages[chatId] = newMessages;
        } else {
          _chatMessages[chatId] = [
            ...(_chatMessages[chatId] ?? []),
            ...newMessages,
          ];
        }
        _currentPages[chatId] = (_currentPages[chatId] ?? 1) + 1;
      }
    } catch (e) {
      _errors[chatId] = e.toString();
    } finally {
      _loadingStates[chatId] = false;
      notifyListeners();
    }
  }

  Future<Message?> sendMessage({
    required String chatId,
    required String content,
    String messageType = 'text',
    List<File>? attachments,
  }) async {
    try {
      List<Map<String, dynamic>>? uploadedAttachments;
      if (attachments != null && attachments.isNotEmpty) {
        uploadedAttachments = await _uploadFiles(attachments);
      }

      final message = await ApiService.sendMessage(
        chatId: chatId,
        content: content,
        messageType: messageType,
        replyToId: _replyToMessage?.id,
        attachments: uploadedAttachments,
      );

      if (_chatMessages[chatId] != null) {
        _chatMessages[chatId]!.insert(0, message);
      } else {
        _chatMessages[chatId] = [message];
      }

      _replyToMessage = null;
      notifyListeners();
      return message;
    } catch (e) {
      _errors[chatId] = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _uploadFiles(List<File> files) async {
    final token = await LocalStorageService().getAuthToken();
    final uri = Uri.parse('https://wisdom-walk-app.onrender.com/api/upload');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to upload files: ${response.statusCode}');
    }
  }

  Future<void> editMessage(String messageId, String content) async {
    try {
      final editedMessage = await ApiService.editMessage(messageId, content);

      // Update message in all chat lists
      for (String chatId in _chatMessages.keys) {
        final messages = _chatMessages[chatId]!;
        final messageIndex = messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          messages[messageIndex] = editedMessage;
          break;
        }
      }

      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error editing message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await ApiService.deleteMessage(messageId);

      // Remove message from all chat lists
      for (String chatId in _chatMessages.keys) {
        final messages = _chatMessages[chatId]!;
        messages.removeWhere((m) => m.id == messageId);
      }

      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error deleting message: $e');
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    try {
      await ApiService.addReaction(messageId, emoji);
      // The reaction update will be handled by real-time updates
    } catch (e) {
      // Handle error
      print('Error adding reaction: $e');
    }
  }

  Future<void> pinMessage(String chatId, String messageId) async {
    try {
      await ApiService.pinMessage(chatId, messageId);

      // Update message pin status
      final messages = _chatMessages[chatId];
      if (messages != null) {
        final messageIndex = messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          // Create updated message with pinned status
          // This would require updating the Message model to be mutable
          // or creating a new instance with updated properties
        }
      }

      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error pinning message: $e');
    }
  }

  Future<Message?> forwardMessage(String messageId, String targetChatId) async {
    try {
      final forwardedMessage = await ApiService.forwardMessage(
        messageId,
        targetChatId,
      );

      // Add forwarded message to target chat
      if (_chatMessages[targetChatId] != null) {
        _chatMessages[targetChatId]!.insert(0, forwardedMessage);
      } else {
        _chatMessages[targetChatId] = [forwardedMessage];
      }

      notifyListeners();
      return forwardedMessage;
    } catch (e) {
      print('Error forwarding message: $e');
      return null;
    }
  }

  void addNewMessage(String chatId, Message message) {
    if (_chatMessages[chatId] != null) {
      _chatMessages[chatId]!.insert(0, message);
    } else {
      _chatMessages[chatId] = [message];
    }
    notifyListeners();
  }

  void clearError(String chatId) {
    _errors[chatId] = null;
    notifyListeners();
  }
}
