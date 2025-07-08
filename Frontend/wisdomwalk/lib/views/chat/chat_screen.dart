import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/local_storage_service.dart';
import '../../services/socket_service.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../providers/message_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isInitialLoad = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _scrollController.addListener(_onScroll);
    _loadInitialMessages();
    _markChatAsRead();
    _connectToSocket();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await _localStorageService.getCurrentUserId();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      context.read<MessageProvider>().loadMessages(widget.chat.id);
    }
  }

  Future<void> _loadInitialMessages() async {
    await context.read<MessageProvider>().loadMessages(
      widget.chat.id,
      refresh: true,
    );
    setState(() => _isInitialLoad = false);
    
    // Scroll to bottom after messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }
void _markChatAsRead() {
  context.read<ChatProvider>().markChatAsRead(widget.chat.id);
}

  Future<void> _connectToSocket() async {
    final token = await _localStorageService.getAuthToken();
    if (token != null) {
      final socketService = SocketService(context);
      socketService.connect(token);
      socketService.joinChat(widget.chat.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildReplyIndicator(),
          MessageInput(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onAttachFile: _attachFile,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.chat.chatImage != null
                ? NetworkImage(widget.chat.chatImage!)
                : null,
            child: widget.chat.chatImage == null
                ? Text(
                    widget.chat.chatName?.isNotEmpty ?? false
                        ? widget.chat.chatName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 16),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.chatName ?? 'Unknown Chat',
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.chat.isOnline == true) 
                  const Text(
                    'Online',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {}, // Implement video call
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {}, // Implement voice call
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'search', child: Text('Search')),
            const PopupMenuItem(value: 'mute', child: Text('Mute')),
            const PopupMenuItem(value: 'block', child: Text('Block')),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final messages = messageProvider.getChatMessages(widget.chat.id);
        final isLoading = messageProvider.isLoading(widget.chat.id);
        final error = messageProvider.getError(widget.chat.id);

        if (_isInitialLoad && messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    messageProvider.clearError(widget.chat.id);
                    _loadInitialMessages();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (messages.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet\nSend the first message!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // This makes latest messages appear at bottom
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final message = messages[index];
            final isCurrentUser = message.sender.id == _currentUserId;

            return MessageBubble(
              message: message,
              isCurrentUser: isCurrentUser,
              onReply: () => _setReplyMessage(message),
              onEdit: () => _editMessage(message),
              onDelete: () => _deleteMessage(message),
              onReact: (emoji) => _addReaction(message, emoji),
              onPin: () => _pinMessage(message),
              onForward: () => _forwardMessage(message),
            );
          },
        );
      },
    );
  }

  Widget _buildReplyIndicator() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.replyToMessage == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replying to ${messageProvider.replyToMessage!.sender.fullName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12, 
                      ),
                    ),
                    Text(
                      messageProvider.replyToMessage!.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => messageProvider.setReplyToMessage(null),
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildPinnedMessageIndicator() {
  final pinnedMessageId = context.read<MessageProvider>().getPinnedMessageId(widget.chat.id);
  if (pinnedMessageId == null) return const SizedBox.shrink();

  final messages = context.read<MessageProvider>().getChatMessages(widget.chat.id);
  Message? pinnedMessage;
  
  try {
    pinnedMessage = messages.firstWhere((m) => m.id == pinnedMessageId);
  } catch (e) {
    return const SizedBox.shrink();
  }

  if (pinnedMessage.content.isEmpty) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.amber[50],
      border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pinned Message', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          pinnedMessage.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

void _handleMenuAction(String action) {
    switch (action) {
      case 'search':
        break;
      case 'mute':
        break;
      case 'block':
        break;
    }
  }

  void _setReplyMessage(Message message) {
    context.read<MessageProvider>().setReplyToMessage(message);
  }

  void _editMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => EditMessageDialog(
        message: message,
        onEdit: (newContent) {
          context.read<MessageProvider>().editMessage(
            message.id,
            newContent,
          );
        },
      ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MessageProvider>().deleteMessage(message.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _addReaction(Message message, String emoji) {
    context.read<MessageProvider>().addReaction(message.id, emoji);
  }

  void _pinMessage(Message message) {
    context.read<MessageProvider>().pinMessage(widget.chat.id, message.id);
  }

  void _forwardMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forward Message'),
        content: const Text('Feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    final messageProvider = context.read<MessageProvider>();
    await messageProvider.sendMessage(
      chatId: widget.chat.id,
      content: content.trim(),
    );
    
    _messageController.clear();
    
    // Scroll to bottom after sending message
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

 Future<void> _attachFile() async {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Photo'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile = await _imagePicker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                final file = File(pickedFile.path);
                await context.read<MessageProvider>().sendMessage(
                  chatId: widget.chat.id,
                  content: 'Photo',
                  messageType: 'image',
                  attachments: [file],
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile = await _imagePicker.pickImage(
                source: ImageSource.camera,
              );
              if (pickedFile != null) {
                final file = File(pickedFile.path);
                await context.read<MessageProvider>().sendMessage(
                  chatId: widget.chat.id,
                  content: 'Photo',
                  messageType: 'image',
                  attachments: [file],
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('Document'),
            onTap: () async {
              Navigator.pop(context);
              // Implement document picker here if needed
            },
          ),
        ],
      ),
    ),
  );
}
}

class EditMessageDialog extends StatefulWidget {
  final Message message;
  final Function(String) onEdit;

  const EditMessageDialog({
    Key? key,
    required this.message,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Enter your message...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onEdit(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}