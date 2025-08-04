import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/user_model.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onReact;
  final VoidCallback? onPin;
  final VoidCallback? onForward;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onReact,
    this.onPin,
    this.onForward,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message.isPinned) _buildPinnedHeader(context),
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser) const SizedBox(width: 16.0),
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser) _buildSenderName(message.sender),
                    GestureDetector(
                      onLongPress: () => _showMessageOptions(context),
                      onDoubleTap: () => _handleDoubleTap(context),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color:
                              isCurrentUser
                                  ? (isDarkMode
                                      ? Colors.blue[800]
                                      : Colors.blue)
                                  : (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200]),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18.0),
                            topRight: const Radius.circular(18.0),
                            bottomLeft: Radius.circular(
                              isCurrentUser ? 18.0 : 4.0,
                            ),
                            bottomRight: Radius.circular(
                              isCurrentUser ? 4.0 : 18.0,
                            ),
                          ),
                        ),
                        child: _buildMessageContent(),
                      ),
                    ),
                    _buildMessageStatus(),
                  ],
                ),
              ),
              if (isCurrentUser) const SizedBox(width: 8.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.push_pin, size: 14.0, color: Colors.orange),
                const SizedBox(width: 4.0),
                Text(
                  'Pinned',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDoubleTap(BuildContext context) {
    if (onReact != null) {
      _showQuickReactions(context);
    }
  }

  void _showQuickReactions(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx + renderBox.size.width / 2 - 100,
            top: position.dy - 50,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      ['❤️', '👍', '😂', '😮', '😢', '😡'].map((emoji) {
                        return GestureDetector(
                          onTap: () {
                            overlayEntry.remove();
                            onReact?.call(emoji);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24.0),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  Widget _buildReactions() {
    // Group reactions by emoji and count
    final reactionGroups = <String, int>{};
    for (final reaction in message.reactions) {
      reactionGroups[reaction.emoji] =
          (reactionGroups[reaction.emoji] ?? 0) + 1;
    }

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.end,
      children:
          reactionGroups.entries.map((entry) {
            return GestureDetector(
              onTap: () => onReact?.call(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: entry.key),
                      if (entry.value > 1)
                        TextSpan(
                          text: ' ${entry.value}',
                          style: const TextStyle(fontSize: 10.0),
                        ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12.0),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSenderName(UserModel sender) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
      child: Text(
        sender.displayName,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.replyTo != null) _buildReplyPreview(),
        if (message.forwardedFrom != null) _buildForwardIndicator(),
        if (message.isPinned) _buildPinnedIndicator(),
        if (message.attachments.isNotEmpty) ..._buildAttachments(),
        Text(message.content, style: const TextStyle(fontSize: 16.0)),
        if (message.reactions.isNotEmpty) _buildReactions(),
      ],
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to ${message.replyTo!.sender.displayName}',
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            message.replyTo!.content,
            style: const TextStyle(fontSize: 12.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildForwardIndicator() {
    return Row(
      children: [
        const Icon(Icons.forward, size: 16.0),
        const SizedBox(width: 4.0),
        Text(
          'Forwarded from ${message.forwardedFrom!.sender.displayName}',
          style: const TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildPinnedIndicator() {
    return Row(
      children: [
        const Icon(Icons.push_pin, size: 16.0),
        const SizedBox(width: 4.0),
        const Text(
          'Pinned',
          style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  List<Widget> _buildAttachments() {
    return message.attachments.map((attachment) {
      if (attachment.fileType.startsWith('image')) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              attachment.type,
              width: 200.0,
              height: 150.0,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200.0,
                  height: 150.0,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200.0,
                  height: 150.0,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, size: 16.0),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  attachment.fileName,
                  style: const TextStyle(fontSize: 12.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget _buildMessageStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(fontSize: 10.0, color: Colors.grey[500]),
          ),
          if (message.isEdited) ...[
            const SizedBox(width: 4.0),
            Text(
              'edited',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (isCurrentUser) ...[
            const SizedBox(width: 4.0),
            Icon(
              Icons.done_all,
              size: 12.0,
              color: message.readBy.length > 1 ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onReply != null)
                _buildOptionTile(
                  context,
                  icon: Icons.reply,
                  label: 'Reply',
                  onTap: () {
                    Navigator.pop(context);
                    onReply!();
                  },
                ),
              if (isCurrentUser && onEdit != null)
                _buildOptionTile(
                  context,
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
              if (isCurrentUser && onDelete != null)
                _buildOptionTile(
                  context,
                  icon: Icons.delete,
                  label: 'Delete',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
              if (onReact != null)
                _buildOptionTile(
                  context,
                  icon: Icons.emoji_emotions,
                  label: 'React',
                  onTap: () {
                    Navigator.pop(context);
                    _showReactionPicker(context);
                  },
                ),
              if (onPin != null)
                _buildOptionTile(
                  context,
                  icon:
                      message.isPinned
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                  label: message.isPinned ? 'Unpin' : 'Pin',
                  onTap: () {
                    Navigator.pop(context);
                    onPin!();
                  },
                ),
              if (onForward != null)
                _buildOptionTile(
                  context,
                  icon: Icons.forward,
                  label: 'Forward',
                  onTap: () {
                    Navigator.pop(context);
                    onForward!();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.iconTheme.color,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showReactionPicker(BuildContext context) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Reaction'),
          content: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children:
                reactions.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onReact?.call(emoji);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 28.0)),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year.toString().substring(2)}';
    }
  }
}
