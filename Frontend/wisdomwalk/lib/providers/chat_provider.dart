import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html; // For browser compatibility
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  String? _userId;
  ChatModel? _selectedChat;
  List<ChatModel> _chats = [];
  bool _isLoading = false;
  bool _isDebug = true; // Manual debug flag

  ChatProvider() {
    _userId = 'user1'; // Example user ID
    _fetchChats();
  }

  List<ChatModel> get chats => _chats;
  ChatModel? get selectedChat => _selectedChat;
  bool get isLoading => _isLoading;

  Future<void> _fetchChats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _chats = await _chatService.fetchChats();
    } catch (e) {
      if (_isDebug) print('Error fetching chats: $e');
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
        orElse: () => _chats[0],
      );
    }
    notifyListeners(); // <-- Keeps your UI updated
  }

  Future<void> sendMessage(String content) async {
    if (_selectedChat != null) {
      final newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _userId!,
        content: content,
        time: _formatTime(DateTime.now()),
        isMe: true,
      );
      _selectedChat!.messages.add(newMessage);
      _selectedChat!.lastMessage = content;
      _selectedChat!.time = newMessage.time;
      notifyListeners();
      await _chatService.sendMessage(_selectedChat!.id, content, _userId!);
    }
  }

  Future<void> sendFile(String chatId, dynamic file) async {
    if (_isDebug)
      print('Uploading file: ${file is File ? file.path : file.name}');
    try {
      if (file is File) {
        // Native platform
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final savedFile = await file.copy('${directory.path}/$fileName');

        if (_selectedChat != null) {
          final newMessage = MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: _userId!,
            content: 'File attached: ${file.path.split('/').last}',
            time: _formatTime(DateTime.now()),
            isMe: true,
            filePath: savedFile.path,
            fileType: _getFileType(file.path),
          );
          _selectedChat!.messages.add(newMessage);
          _selectedChat!.lastMessage = newMessage.content;
          _selectedChat!.time = newMessage.time;
          notifyListeners();
        }
      } else if (file is html.File) {
        // Browser platform
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoadEnd.first; // Wait for Data URL
        final dataUrl = reader.result as String;

        if (_selectedChat != null) {
          final newMessage = MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: _userId!,
            content: 'File attached: ${file.name}',
            time: _formatTime(DateTime.now()),
            isMe: true,
            filePath: dataUrl, // Use Data URL for preview
            fileType: _getFileType(file.name),
          );
          _selectedChat!.messages.add(newMessage);
          _selectedChat!.lastMessage = newMessage.content;
          _selectedChat!.time = newMessage.time;
          notifyListeners();
        }
      }
    } catch (e) {
      if (_isDebug) print('Error uploading file: $e');
    }
  }

  String _getFileType(String path) {
    final extension = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(extension)) return 'image';
    if (['mp4'].contains(extension)) return 'video';
    if (['pdf'].contains(extension)) return 'pdf';
    return 'unknown';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  void makeCall() {
    if (_isDebug) print('Making call to ${_selectedChat?.name}');
  }

  void startVideoCall() {
    if (_isDebug) print('Starting video call with ${_selectedChat?.name}');
  }
}
