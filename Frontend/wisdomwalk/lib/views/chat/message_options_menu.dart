import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/message_model.dart';
import '../../providers/chat_provider.dart';

void showMessageOptionsMenu({
  required BuildContext context,
  required Message message,
  required bool isMe,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditMessageDialog(context, message);
              },
            ),
          if (isMe)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ChatProvider>(context, listen: false)
                    .deleteMessage(message.id);
              },
            ),
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              // Implement reply
            },
          ),
          ListTile(
            leading: const Icon(Icons.forward),
            title: const Text('Forward'),
            onTap: () {
              Navigator.pop(context);
              // Implement forward
            },
          ),
          if (!message.isPinned)
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Pin'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ChatProvider>(context, listen: false)
                    .pinMessage(message.id);
              },
            ),
          if (message.isPinned)
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Unpin'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<ChatProvider>(context, listen: false)
                    .pinMessage(message.id);
              },
            ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: const Text('React'),
            onTap: () {
              Navigator.pop(context);
              _showReactionMenu(context, message);
            },
          ),
        ],
      );
    },
  );
}

void _showEditMessageDialog(BuildContext context, Message message) {
  final controller = TextEditingController(text: message.content);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
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
              Provider.of<ChatProvider>(context, listen: false).editMessage(
                message.id,
                controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _showReactionMenu(BuildContext context, Message message) {
  final emojis = ['❤️', '😂', '😮', '😢', '👍', '👎'];
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
        height: 100,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Provider.of<ChatProvider>(context, listen: false).addReaction(
                  message.id,
                  emojis[index],
                );
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}