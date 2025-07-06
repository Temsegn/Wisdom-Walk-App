import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/services/socket_service.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<MessageProvider>().loadMessages(
        widget.chat.id,
        refresh: true,
      );
      context.read<ChatProvider>().markChatAsRead(widget.chat.id);
      final token =
          await _localStorageService.getAuthToken(); // Get the actual token
      final socketService = SocketService(context);
      socketService.connect(token!); // Use token from local storage
      socketService.joinChat(widget.chat.id);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<MessageProvider>().loadMessages(widget.chat.id);
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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  widget.chat.chatImage != null
                      ? NetworkImage(widget.chat.chatImage!)
                      : null,
              child:
                  widget.chat.chatImage == null
                      ? Text(
                        widget.chat.chatName?.substring(0, 1).toUpperCase() ??
                            'C',
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Implement voice call
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'search', child: Text('Search')),
                  const PopupMenuItem(value: 'mute', child: Text('Mute')),
                  const PopupMenuItem(value: 'block', child: Text('Block')),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final messages = messageProvider.getChatMessages(
                  widget.chat.id,
                );
                final isLoading = messageProvider.isLoading(widget.chat.id);
                final error = messageProvider.getError(widget.chat.id);

                if (messages.isEmpty && isLoading) {
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
                            messageProvider.loadMessages(
                              widget.chat.id,
                              refresh: true,
                            );
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
                  reverse: true,
                  itemCount:
                      messages.length +
                      (messageProvider.hasMoreMessages(widget.chat.id) ? 1 : 0),
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
                    return MessageBubble(
                      message: message,
                      onReply: () => _setReplyMessage(message),
                      onEdit: () => _editMessage(message),
                      onDelete: () => _deleteMessage(message),
                      onReact: (emoji) => _addReaction(message, emoji),
                      onPin: () => _pinMessage(message),
                      onForward: () => _forwardMessage(message), 
                      isCurrentUser: message.sender.id ==
                          _localStorageService.getCurrentUserId(), 
                    );
                  },
                );
              },
            ),
          ),
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              if (messageProvider.replyToMessage != null) {
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
                        onPressed: () {
                          messageProvider.setReplyToMessage(null);
                        },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          MessageInput(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onAttachFile: _attachFile,
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
      builder:
          (context) => EditMessageDialog(
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
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
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
      builder:
          (context) => AlertDialog(
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
    await context.read<MessageProvider>().sendMessage(
      chatId: widget.chat.id,
      content: content.trim(),
    );
    _messageController.clear();
  }

  Future<void> _attachFile() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      await context.read<MessageProvider>().sendMessage(
                        chatId: widget.chat.id,
                        content: 'Photo',
                        messageType: 'image',
                        attachments: [File(image.path)],
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      await context.read<MessageProvider>().sendMessage(
                        chatId: widget.chat.id,
                        content: 'Photo',
                        messageType: 'image',
                        attachments: [File(image.path)],
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: const Text('Document'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement document picker
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
