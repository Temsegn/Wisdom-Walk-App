import 'package:flutter/foundation.dart';
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
  Message copyWith({
    String? id,
    String? chatId,
    UserModel? sender,
    String? content,
    String? encryptedContent,
    MessageType? messageType,
    List<MessageAttachment>? attachments,
    Scripture? scripture,
    String? forwardedFromId,
    bool? isPinned,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    List<MessageRead>? readBy,
    List<MessageReaction>? reactions,
    String? replyToId,
    Message? replyTo,
    Message? forwardedFrom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      messageType: messageType ?? this.messageType,
      attachments: attachments ?? this.attachments,
      scripture: scripture ?? this.scripture,
      forwardedFromId: forwardedFromId ?? this.forwardedFromId,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      replyTo: replyTo ?? this.replyTo,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    // Helper functions
    String safeString(dynamic value) => value?.toString() ?? '';
    bool safeBool(dynamic value) => value == true;
    DateTime? parseDate(dynamic date) => date != null ? DateTime.tryParse(date.toString()) : null;
    
    UserModel parseSender(dynamic senderData) {
      if (senderData is Map<String, dynamic>) {
        try {
          return UserModel.fromJson(senderData);
        } catch (e) {
          debugPrint('Failed to parse sender: $e');
          return UserModel.empty();
        }
      }
      return UserModel.empty();
    }

    Message? parseMessage(dynamic messageData) {
      if (messageData is Map<String, dynamic>) {
        try {
          return Message.fromJson(messageData);
        } catch (e) {
          debugPrint('Failed to parse message: $e');
        }
      }
      return null;
    }

    try {
      return Message(
        id: safeString(json['_id'] ?? json['id']),
        chatId: safeString(json['chat']),
        sender: parseSender(json['sender']),
        content: safeString(json['content']),
        encryptedContent: json['encryptedContent']?.toString(),
        messageType: MessageType.values.firstWhere(
          (e) => e.name == (json['messageType']?.toString().toLowerCase() ?? 'text'),
          orElse: () => MessageType.text,
        ),
        attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => MessageAttachment.fromJson(e))
            .whereType<MessageAttachment>()
            .toList() ?? [],
        scripture: json['scripture'] != null 
            ? Scripture.fromJson(json['scripture']) 
            : null,
        forwardedFromId: json['forwardedFrom']?.toString(),
        isPinned: safeBool(json['isPinned']),
        isEdited: safeBool(json['isEdited']),
        editedAt: parseDate(json['editedAt']),
        isDeleted: safeBool(json['isDeleted']),
        deletedAt: parseDate(json['deletedAt']),
        readBy: (json['readBy'] as List<dynamic>?)
            ?.map((e) => MessageRead.fromJson(e))
            .whereType<MessageRead>()
            .toList() ?? [],
        reactions: (json['reactions'] as List<dynamic>?)
            ?.map((e) => MessageReaction.fromJson(e))
            .whereType<MessageReaction>()
            .toList() ?? [],
        replyToId: json['replyTo'] is String ? json['replyTo']?.toString() : null,
        replyTo: parseMessage(json['replyTo']),
        forwardedFrom: parseMessage(json['forwardedFrom']),
        createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
        updatedAt: parseDate(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing Message: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Problematic JSON: $json');
      throw FormatException('Failed to parse message: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
      'forwardedFrom': forwardedFrom?.toJson(),
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
      type: json['type']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
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
      verse: json['verse']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
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
      userId: json['user']?.toString() ?? '',
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? '') ?? DateTime.now(),
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
      userId: json['user']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
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