import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.setCurrentChat(widget.chat);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.chat.displayImage != null
                  ? NetworkImage(widget.chat.displayImage!)
                  : null,
              child: widget.chat.displayImage == null
                  ? Text(widget.chat.displayName[0])
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chat.displayName),
                if (widget.chat.type == 'direct')
                  Text(
                    widget.chat.otherParticipant?.isOnline ?? false
                        ? 'Online'
                        : 'Last seen ${widget.chat.lastActivityFormatted}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.error != null
                    ? Center(child: Text('Error: ${chatProvider.error}'))
                    : chatProvider.currentChatMessages.isEmpty
                        ? Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final provider = Provider.of<ChatProvider>(context, listen: false);
                                if (provider.currentChat == null) {
                                  await provider.createDirectChat(widget.chat.otherParticipant!.id);
                                }
                                await provider.sendMessage("Hi 👋");
                              },
                              icon: const Icon(Icons.message),
                              label: const Text("Say Hi 👋"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: chatProvider.currentChatMessages.length,
                            itemBuilder: (context, index) {
                              final message = chatProvider.currentChatMessages[
                                  chatProvider.currentChatMessages.length - 1 - index];
                              return _buildMessageItem(message);
                            },
                          ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final isMe = message.senderId ==
        Provider.of<ChatProvider>(context, listen: false).currentUser?.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.sender != null && !isMe)
              Text(
                message.sender!.displayName ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            if (message.replyTo != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Replying to a message',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),
            if (message.content != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(message.content!),
              ),
            if (message.attachments != null && message.attachments!.isNotEmpty)
              ...message.attachments!.map((attachment) {
                if (attachment.fileType == 'image') {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(
                      attachment.type,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        const Icon(Icons.insert_drive_file),
                        Text(attachment.fileName),
                      ],
                    ),
                  );
                }
              }),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timeFormatted,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (message.isEdited)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'edited',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            if (message.reactions.isNotEmpty)
              Wrap(
                spacing: 4,
                children: message.reactions
                    .map((reaction) => Chip(
                          label: Text(reaction.emoji),
                          backgroundColor: Colors.grey[300],
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // Implement attachment logic
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      _messageController.text.trim(),
    );
    _messageController.clear();
  }

  void _showChatOptions(BuildContext context) {
    final chat = widget.chat;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: Text(chat.isMuted ? 'Unmute Chat' : 'Mute Chat'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ChatProvider>(context, listen: false)
                    .muteCurrentChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Chat'),
              onTap: () {
                Navigator.pop(context);
                // Implement delete chat logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                // Implement block user logic
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
