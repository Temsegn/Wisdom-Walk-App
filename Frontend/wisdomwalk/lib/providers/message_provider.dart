import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/services/local_storage_service.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  final Map<String, List<Message>> _chatMessages = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errors = {};
  final Map<String, int> _currentPages = {};
  final Map<String, bool> _hasMoreMessages = {};
    final Map<String, String> _pinnedMessages = {}; // chatId: messageId

  Message? _replyToMessage;

  List<Message> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  bool isLoading(String chatId) => _loadingStates[chatId] ?? false;
  String? getError(String chatId) => _errors[chatId];
  bool hasMoreMessages(String chatId) => _hasMoreMessages[chatId] ?? true;
  Message? get replyToMessage => _replyToMessage;

  void setReplyToMessage(Message? message) {
    _replyToMessage = message;
    notifyListeners();
  }
 
  Future<void> loadMessages(String chatId, {bool refresh = false}) async {
    if (chatId.startsWith('preview-')) {
      _chatMessages[chatId] = [];
      _hasMoreMessages[chatId] = false;
      _loadingStates[chatId] = false;
      notifyListeners();
      return;
    }

    if (_loadingStates[chatId] == true || 
        (!refresh && (_hasMoreMessages[chatId] ?? true) == false)) {
      return;
    }

    _loadingStates[chatId] = true;
    if (refresh) {
      _currentPages[chatId] = 1;
      _chatMessages.remove(chatId);
      _hasMoreMessages[chatId] = true;
    }
    notifyListeners();

    try {
      final newMessages = await apiService.getChatMessages(
        chatId,
        page: _currentPages[chatId] ?? 1,
        limit: 50,
      );

      if (newMessages.isEmpty) {
        _hasMoreMessages[chatId] = false;
      } else {
        final currentMessages = _chatMessages[chatId] ?? [];
        _chatMessages[chatId] = refresh 
            ? newMessages 
            : [...currentMessages, ...newMessages];
        _currentPages[chatId] = (_currentPages[chatId] ?? 1) + 1;
      }
      _errors.remove(chatId);
    } catch (e) {
      _errors[chatId] = e.toString();
      debugPrint('Error loading messages for $chatId: $e');
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
      _loadingStates[chatId] = true;
      notifyListeners();

      List<Map<String, dynamic>>? uploadedAttachments;
      if (attachments != null && attachments.isNotEmpty) {
        uploadedAttachments = await _uploadFiles(attachments);
      }

      final message = await apiService.sendMessage(
        chatId: chatId,
        content: content,
        messageType: messageType,
        replyToId: _replyToMessage?.id,
        attachments: uploadedAttachments,
      );

      addNewMessage(chatId, message);
      _replyToMessage = null;
      _errors.remove(chatId);
      return message;
    } catch (e) {
      _errors[chatId] = e.toString();
      notifyListeners();
      return null;
    } finally {
      _loadingStates[chatId] = false;
      notifyListeners();
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
      final editedMessage = await apiService.editMessage(messageId, content);
      _updateMessageInChats(editedMessage);
    } catch (e) {
      debugPrint('Error editing message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await apiService.deleteMessage(messageId);
      _removeMessageFromChats(messageId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }
// Replace existing addReaction with:
Future<void> addReaction(String messageId, String emoji) async {
  try {
    final chatId = _findChatIdForMessage(messageId);
    if (chatId != null) {
      await apiService.addReaction(messageId, emoji);
      // Create a new reaction object
      final reaction = MessageReaction(
        emoji: emoji,
        userId: await LocalStorageService().getCurrentUserId() ?? '',
        createdAt: DateTime.now(),
      );
      updateMessageReaction(chatId, messageId, reaction);
    }
  } catch (e) {
    debugPrint('Error adding reaction: $e');
    rethrow;
  }
}

// Replace existing pinMessage with:
Future<void> pinMessage(String chatId, String messageId) async {
  try {
    await apiService.pinMessage(chatId, messageId);
    updateMessagePinnedStatus(chatId, messageId, true);
  } catch (e) {
    debugPrint('Error pinning message: $e');
    rethrow;
  }
}

// Add this helper method:
String? _findChatIdForMessage(String messageId) {
  for (final entry in _chatMessages.entries) {
    if (entry.value.any((m) => m.id == messageId)) {
      return entry.key;
    }
  }
  return null;
}
  Future<Message?> forwardMessage(String messageId, String targetChatId) async {
    try {
      final forwardedMessage = await apiService.forwardMessage(
        messageId,
        targetChatId,
      );
      addNewMessage(targetChatId, forwardedMessage);
      return forwardedMessage;
    } catch (e) {
      debugPrint('Error forwarding message: $e');
      return null;
    }
  }

  void addNewMessage(String chatId, Message message) {
    _chatMessages[chatId] = [message, ..._chatMessages[chatId] ?? []];
    notifyListeners();
  }

  void clearError(String chatId) {
    _errors.remove(chatId);
    notifyListeners();
  }

  // Helper methods
  void _updateMessageInChats(Message updatedMessage) {
    for (final chatId in _chatMessages.keys) {
      final messages = _chatMessages[chatId]!;
      final index = messages.indexWhere((m) => m.id == updatedMessage.id);
      if (index != -1) {
        _chatMessages[chatId]![index] = updatedMessage;
        notifyListeners();
        break;
      }
    }
  }

  void _removeMessageFromChats(String messageId) {
    for (final chatId in _chatMessages.keys) {
      _chatMessages[chatId]!.removeWhere((m) => m.id == messageId);
    }
    notifyListeners();
  }

  // Add this with other methods
void updateMessageReaction(String chatId, String messageId, MessageReaction reaction) {
  final messages = _chatMessages[chatId];
  if (messages != null) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      // Create new message with updated reactions
      final updatedMessage = messages[index].copyWith(
        reactions: [...messages[index].reactions, reaction],
        updatedAt: DateTime.now(),
      );
      _chatMessages[chatId]![index] = updatedMessage;
      notifyListeners();
    }
  }
}

void updateMessagePinnedStatus(String chatId, String messageId, bool isPinned) {
  final messages = _chatMessages[chatId];
  if (messages != null) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      // Update pinned messages map
      if (isPinned) {
        _pinnedMessages[chatId] = messageId;
      } else if (_pinnedMessages[chatId] == messageId) {
        _pinnedMessages.remove(chatId);
      }

      // Create new message with updated pinned status
      final updatedMessage = messages[index].copyWith(
        isPinned: isPinned,
        updatedAt: DateTime.now(),
      );
      _chatMessages[chatId]![index] = updatedMessage;
      notifyListeners();
    }
  }
}

String? getPinnedMessageId(String chatId) => _pinnedMessages[chatId];
}