import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wisdomwalk/models/chat_message.dart';
import 'package:wisdomwalk/utils/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: message.sender.profilePicture != null
                  ? NetworkImage(message.sender.profilePicture!)
                  : null,
              child: message.sender.profilePicture == null
                  ? Text(message.sender.firstName[0])
                  : null,
            ),
          if (!isMe) const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && message.messageType != 'scripture')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.sender.firstName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white70 : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  // Message content based on type
                  if (message.messageType == 'text')
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    )
                  else if (message.messageType == 'scripture')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scripture',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.white : AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.scripture?['verse'] ?? '',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          message.scripture?['reference'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else if (message.messageType == 'file' && message.attachments != null && message.attachments!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.attachments!.first.fileType == 'image')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              message.attachments!.first.url,
                              width: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.error),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.white24 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  color: isMe ? Colors.white : AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    message.attachments!.first.fileName,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (message.content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  
                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(message.createdAt),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        if (message.isEdited)
                          Text(
                            ' (edited)',
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[600],
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: message.sender.profilePicture != null
                  ? NetworkImage(message.sender.profilePicture!)
                  : null,
              child: message.sender.profilePicture == null
                  ? Text(message.sender.firstName[0])
                  : null,
            ),
        ],
      ),
    );
  }
}
