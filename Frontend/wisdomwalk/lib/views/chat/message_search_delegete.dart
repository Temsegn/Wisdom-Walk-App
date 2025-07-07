import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/message_model.dart';
import 'package:wisdomwalk/providers/message_provider.dart';
import 'package:wisdomwalk/services/api_service.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/views/chat/chat_screen.dart';
import 'package:wisdomwalk/widgets/message_bubble.dart';
 


 class MessageSearchDelegate extends SearchDelegate {
  final String chatId;
  final MessageProvider messageProvider;

  MessageSearchDelegate({required this.chatId, required this.messageProvider});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search query'));
    }

    return FutureBuilder<List<Message>>(
      future: messageProvider.apiService.searchMessages(chatId, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return const Center(child: Text('No messages found'));
        }
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return MessageBubble(
              message: message,
              isCurrentUser: message.sender.id == LocalStorageService().getCurrentUserId(),
              onReply: () => messageProvider.setReplyToMessage(message),
              onEdit: () => _editMessage(context, message),
              onDelete: () => _deleteMessage(context, message),
              onReact: (emoji) => messageProvider.addReaction(message.id, emoji),
              onPin: () => messageProvider.pinMessage(chatId, message.id),
              onForward: () => _forwardMessage(context, message),
            );
          },
        );
      },
    );
  }

  void _editMessage(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => EditMessageDialog(
        message: message,
        onEdit: (newContent) {
          messageProvider.editMessage(message.id, newContent);
        },
      ),
    );
  }

  void _deleteMessage(BuildContext context, Message message) {
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
              messageProvider.deleteMessage(message.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _forwardMessage(BuildContext context, Message message) {
    // Implement forward message dialog
  }
}