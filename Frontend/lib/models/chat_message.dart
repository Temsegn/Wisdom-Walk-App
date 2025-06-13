import 'package:wisdomwalk/models/user.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final User sender;
  final String content;
  final String messageType;
  final List<Attachment>? attachments;
  final Map<String, dynamic>? scripture;
  final ChatMessage? replyTo;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final List<ReadReceipt> readBy;
  final List<MessageReaction> reactions;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.messageType,
    this.attachments,
    this.scripture,
    this.replyTo,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    required this.readBy,
    required this.reactions,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    List<ReadReceipt> readBy = [];
    if (json['readBy'] != null) {
      readBy = (json['readBy'] as List)
          .map((receipt) => ReadReceipt.fromJson(receipt))
          .toList();
    }

    List<MessageReaction> reactions = [];
    if (json['reactions'] != null) {
      reactions = (json['reactions'] as List)
          .map((reaction) => MessageReaction.fromJson(reaction))
          .toList();
    }

    List<Attachment>? attachments;
    if (json['attachments'] != null) {
      attachments = (json['attachments'] as List)
          .map((attachment) => Attachment.fromJson(attachment))
          .toList();
    }

    return ChatMessage(
      id: json['_id'],
      chatId: json['chat'],
      sender: User.fromJson(json['sender']),
      content: json['content'],
      messageType: json['messageType'],
      attachments: attachments,
      scripture: json['scripture'],
      replyTo: json['replyTo'] != null ? ChatMessage.fromJson(json['replyTo']) : null,
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      readBy: readBy,
      reactions: reactions,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ReadReceipt {
  final String userId;
  final DateTime readAt;

  ReadReceipt({
    required this.userId,
    required this.readAt,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      userId: json['user'],
      readAt: DateTime.parse(json['readAt']),
    );
  }
}

class MessageReaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  MessageReaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['user'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Attachment {
  final String url;
  final String fileType;
  final String fileName;

  Attachment({
    required this.url,
    required this.fileType,
    required this.fileName,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      url: json['type'], // In the API, the URL is stored in the 'type' field
      fileType: json['fileType'],
      fileName: json['fileName'],
    );
  }
}
