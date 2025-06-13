import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wisdomwalk/models/chat.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/screens/chat_screen.dart';
import 'package:wisdomwalk/utils/constants.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Chat> _chats = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChats();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    // Listen for new chat creation
    if (socketProvider.socket != null) {
      socketProvider.socket!.on('chat:new_chat_created', (data) {
        _fetchChats(); // Refresh the chat list
      });
      
      // Listen for new messages to update last message
      socketProvider.socket!.on('chat:new_message', (data) {
        final chatId = data['chatId'];
        // Find the chat and update its last message
        final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _fetchChats(); // Refresh to get updated unread counts
        }
      });
    }
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch chats';
          _isLoading = false;
        });
        return;
      }

      final List<Chat> chats = (responseData['data'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();

      setState(() {
        _chats.clear();
        _chats.addAll(chats);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshChats() async {
    await _fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search users screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create new chat screen
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshChats,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshChats,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chats.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No chats yet'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to search users screen
                                },
                                child: const Text('Start a Chat'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _chats.length,
                          itemBuilder: (context, index) {
                            final chat = _chats[index];
                            final chatName = chat.getChatName(userId);
                            final chatImage = chat.getChatImage(userId);
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: chatImage != null
                                    ? NetworkImage(chatImage)
                                    : null,
                                child: chatImage == null
                                    ? Text(chatName[0])
                                    : null,
                              ),
                              title: Text(
                                chatName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.lastMessageId != null
                                          ? 'Last message...' // In a real app, you'd fetch the actual message content
                                          : 'No messages yet',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    timeago.format(chat.lastActivity),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (chat.unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        chat.unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(chat: chat),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
    );
  }
}
