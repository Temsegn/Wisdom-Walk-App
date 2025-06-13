import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/chat.dart';
import 'package:wisdomwalk/models/chat_message.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/utils/constants.dart';
import 'package:wisdomwalk/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  Timer? _typingTimer;
  Map<String, dynamic> _typingUsers = {};

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _joinChatRoom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _leaveChatRoom();
    super.dispose();
  }

  void _joinChatRoom() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    if (socketProvider.isConnected) {
      socketProvider.joinChat(widget.chat.id);
      
      // Listen for new messages
      socketProvider.socket!.on('chat:new_message', (data) {
        if (data['chatId'] == widget.chat.id) {
          final message = ChatMessage.fromJson(data['message']);
          setState(() {
            _messages.insert(0, message);
          });
          
          // Mark message as read
          socketProvider.markMessagesRead(widget.chat.id, message.id);
        }
      });
      
      // Listen for typing indicators
      socketProvider.socket!.on('chat:user_typing', (data) {
        if (data['chatId'] == widget.chat.id) {
          final userId = data['userId'];
          final userName = data['userName'];
          
          setState(() {
            _typingUsers[userId] = userName;
          });
        }
      });
      
      socketProvider.socket!.on('chat:user_stopped_typing', (data) {
        if (data['chatId'] == widget.chat.id) {
          final userId = data['userId'];
          
          setState(() {
            _typingUsers.remove(userId);
          });
        }
      });
      
      // Listen for message reactions
      socketProvider.socket!.on('chat:reaction_updated', (data) {
        if (data['chatId'] == widget.chat.id) {
          final messageId = data['messageId'];
          final reactions = data['reactions'];
          
          setState(() {
            final messageIndex = _messages.indexWhere((m) => m.id == messageId);
            if (messageIndex != -1) {
              // Update message reactions
              // In a real app, you'd create a new message with updated reactions
            }
          });
        }
      });
      
      // Listen for message deletions
      socketProvider.socket!.on('chat:message_deleted', (data) {
        if (data['chatId'] == widget.chat.id) {
          final messageId = data['messageId'];
          
          setState(() {
            final messageIndex = _messages.indexWhere((m) => m.id == messageId);
            if (messageIndex != -1) {
              // Mark message as deleted
              // In a real app, you'd create a new message with isDeleted = true
            }
          });
        }
      });
    }
  }

  void _leaveChatRoom() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    if (socketProvider.isConnected) {
      socketProvider.leaveChat(widget.chat.id);
      
      // Remove listeners
      socketProvider.socket!.off('chat:new_message');
      socketProvider.socket!.off('chat:user_typing');
      socketProvider.socket!.off('chat:user_stopped_typing');
      socketProvider.socket!.off('chat:reaction_updated');
      socketProvider.socket!.off('chat:message_deleted');
    }
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/chats/${widget.chat.id}/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch messages';
          _isLoading = false;
        });
        return;
      }

      final List<ChatMessage> messages = (responseData['data'] as List)
          .map((message) => ChatMessage.fromJson(message))
          .toList();

      setState(() {
        _messages.clear();
        _messages.addAll(messages);
        _isLoading = false;
      });
      
      // Mark all messages as read
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      if (socketProvider.isConnected && _messages.isNotEmpty) {
        socketProvider.markMessagesRead(widget.chat.id, _messages.first.id);
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    if (socketProvider.isConnected) {
      // Send via Socket.io for real-time delivery
      socketProvider.sendMessage(widget.chat.id, message);
      _messageController.clear();
      
      // Stop typing indicator
      socketProvider.stopTyping(widget.chat.id);
      _isTyping = false;
    } else {
      // Fallback to REST API
      _sendMessageViaRest(message);
    }
  }

  Future<void> _sendMessageViaRest(String message) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/chats/${widget.chat.id}/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: json.encode({
          'content': message,
          'messageType': 'text',
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to send message')),
        );
        return;
      }

      _messageController.clear();
      
      // Refresh messages to see the new one
      _fetchMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  void _handleTyping() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    if (socketProvider.isConnected && !_isTyping) {
      socketProvider.startTyping(widget.chat.id);
      _isTyping = true;
      
      // Auto-stop typing after 3 seconds of inactivity
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        socketProvider.stopTyping(widget.chat.id);
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id ?? '';
    final chatName = widget.chat.getChatName(userId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.chat.getChatImage(userId) != null
                  ? NetworkImage(widget.chat.getChatImage(userId)!)
                  : null,
              child: widget.chat.getChatImage(userId) == null
                  ? Text(chatName[0])
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatName,
                  style: const TextStyle(fontSize: 16),
                ),
                if (_typingUsers.isNotEmpty)
                  Text(
                    '${_typingUsers.values.first} is typing...',
                    style: const TextStyle(fontSize: 12),
                  )
                else
                  Text(
                    widget.chat.type == 'direct' ? 'Online' : '${widget.chat.participants.length} members',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show chat options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Typing indicators
          if (_typingUsers.isNotEmpty && _typingUsers.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey[200],
              child: Text(
                '${_typingUsers.values.length} people are typing...',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          
          // Messages list
          Expanded(
            child: _error != null
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
                          onPressed: _fetchMessages,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? const Center(child: Text('No messages yet'))
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isMe = message.sender.id == userId;
                              
                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                              );
                            },
                          ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // Show attachment options
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => _handleTyping(),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppTheme.primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
