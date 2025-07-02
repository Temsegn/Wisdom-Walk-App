import 'user_model.dart';

class Message {
  final String id;
  final String chatId;
  final UserModel sender;
  final String content;
  final String? encryptedContent;
  final MessageType messageType;
  final List<MessageAttachment> attachments;
  final Scripture? scripture;
  final String? forwardedFromId;
  final bool isPinned;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final List<MessageRead> readBy;
  final List<MessageReaction> reactions;
  final String? replyToId;
  final Message? replyTo;
  final Message? forwardedFrom;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    this.encryptedContent,
    this.messageType = MessageType.text,
    this.attachments = const [],
    this.scripture,
    this.forwardedFromId,
    this.isPinned = false,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.readBy = const [],
    this.reactions = const [],
    this.replyToId,
    this.replyTo,
    this.forwardedFrom,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      chatId: json['chat'] ?? '',
      sender: UserModel.fromJson(json['sender']),
      content: json['content'] ?? '',
      encryptedContent: json['encryptedContent'],
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['messageType'],
        orElse: () => MessageType.text,
      ),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e))
          .toList() ?? [],
      scripture: json['scripture'] != null 
          ? Scripture.fromJson(json['scripture']) 
          : null,
      forwardedFromId: json['forwardedFrom'],
      isPinned: json['isPinned'] ?? false,
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt']) 
          : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt']) 
          : null,
      readBy: (json['readBy'] as List<dynamic>?)
          ?.map((e) => MessageRead.fromJson(e))
          .toList() ?? [],
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e))
          .toList() ?? [],
      replyToId: json['replyTo'] is String ? json['replyTo'] : null,
      replyTo: json['replyTo'] is Map ? Message.fromJson(json['replyTo']) : null,
      forwardedFrom: json['forwardedFrom'] is Map 
          ? Message.fromJson(json['forwardedFrom']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat': chatId,
      'sender': sender.toJson(),
      'content': content,
      'encryptedContent': encryptedContent,
      'messageType': messageType.name,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'scripture': scripture?.toJson(),
      'forwardedFrom': forwardedFromId,
      'isPinned': isPinned,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'readBy': readBy.map((e) => e.toJson()).toList(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'replyTo': replyToId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum MessageType { text, image, scripture, prayer, video, document }

class MessageAttachment {
  final String type;
  final String fileType;
  final String fileName;

  MessageAttachment({
    required this.type,
    required this.fileType,
    required this.fileName,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      type: json['type'] ?? '',
      fileType: json['fileType'] ?? '',
      fileName: json['fileName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'fileType': fileType,
      'fileName': fileName,
    };
  }
}

class Scripture {
  final String verse;
  final String reference;

  Scripture({
    required this.verse,
    required this.reference,
  });

  factory Scripture.fromJson(Map<String, dynamic> json) {
    return Scripture(
      verse: json['verse'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verse': verse,
      'reference': reference,
    };
  }
}

class MessageRead {
  final String userId;
  final DateTime readAt;

  MessageRead({
    required this.userId,
    required this.readAt,
  });

  factory MessageRead.fromJson(Map<String, dynamic> json) {
    return MessageRead(
      userId: json['user'] ?? '',
      readAt: DateTime.parse(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'readAt': readAt.toIso8601String(),
    };
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
      userId: json['user'] ?? '',
      emoji: json['emoji'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
