import 'package:flutter/foundation.dart';
import 'package:wisdomwalk/models/user_model.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final String? encryptedContent;
  final String messageType;
  final List<Attachment>? attachments;
  final Scripture? scripture;
  final String? forwardedFrom;
  final bool isPinned;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final List<ReadReceipt> readBy;
  final List<Reaction> reactions;
  final String? replyTo;
  final DateTime createdAt;
  final UserModel? sender; // Populated sender info

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.encryptedContent,
    required this.messageType,
    this.attachments,
    this.scripture,
    this.forwardedFrom,
    this.isPinned = false,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    required this.readBy,
    required this.reactions,
    this.replyTo,
    required this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      chatId: json['chat'],
      senderId: json['sender'],
      content: json['content'],
      encryptedContent: json['encryptedContent'],
      messageType: json['messageType'] ?? 'text',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((e) => Attachment.fromJson(e))
              .toList()
          : null,
      scripture: json['scripture'] != null
          ? Scripture.fromJson(json['scripture'])
          : null,
      forwardedFrom: json['forwardedFrom'],
      isPinned: json['isPinned'] ?? false,
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      readBy: (json['readBy'] as List)
          .map((e) => ReadReceipt.fromJson(e))
          .toList(),
      reactions: (json['reactions'] as List)
          .map((e) => Reaction.fromJson(e))
          .toList(),
      replyTo: json['replyTo'],
      createdAt: DateTime.parse(json['createdAt']),
      sender: json['sender'] != null ? UserModel.fromJson(json['sender']) : null,
    );
  }

  String get timeFormatted {
    return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isVideo => messageType == 'video';
  bool get isDocument => messageType == 'document';
  bool get isScripture => messageType == 'scripture';
  bool get isPrayer => messageType == 'prayer';
}

class Attachment {
  final String type;
  final String fileType;
  final String fileName;

  Attachment({
    required this.type,
    required this.fileType,
    required this.fileName,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: json['type'],
      fileType: json['fileType'],
      fileName: json['fileName'],
    );
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
      verse: json['verse'],
      reference: json['reference'],
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

class Reaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  Reaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      userId: json['user'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}