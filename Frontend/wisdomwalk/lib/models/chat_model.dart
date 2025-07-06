import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'user_model.dart';
import 'message_model.dart';

enum ChatType { direct, group }

class Chat {
  final String id;
  final List<UserModel> participants;
  final ChatType type;
  final String? groupName;
  final String? groupDescription;
  final String? groupAdminId;
  final String? lastMessageId;
  final Message? lastMessage;
  final DateTime? lastActivity;
  final bool isActive;
  final List<String> pinnedMessages;
  final List<ParticipantSetting> participantSettings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int unreadCount;
  final String? chatName;
  final String? chatImage;
  final bool? isOnline;
  final DateTime? lastActive;

  Chat({
    required this.id,
    required this.participants,
    this.type = ChatType.direct,
    this.groupName,
    this.groupDescription,
    this.groupAdminId,
    this.lastMessageId,
    this.lastMessage,
    this.lastActivity,
    this.isActive = true,
    this.pinnedMessages = const [],
    this.participantSettings = const [],
    this.createdAt,
    this.updatedAt,
    this.unreadCount = 0,
    this.chatName,
    this.chatImage,
    this.isOnline,
    this.lastActive,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    try {
      // Helper functions for safe parsing
      String? parseString(dynamic value) => value?.toString();
      bool? parseBool(dynamic value) => value is bool ? value : null;
      int? parseInt(dynamic value) => value is int ? value : null;

      // Parse participants - handles both String IDs and User objects
      final participants = <UserModel>[];
      if (json['participants'] is List) {
        for (var participant in json['participants']) {
          if (participant is Map<String, dynamic>) {
            try {
              participants.add(UserModel.fromJson(participant));
            } catch (e) {
              debugPrint('Failed to parse participant: $participant');
            }
          }
        }
      }

      // Parse chat type with fallback
      final chatType = ChatType.values.firstWhere(
        (e) => e.toString().split('.').last == 
              (json['type']?.toString().toLowerCase() ?? 'direct'),
        orElse: () => ChatType.direct,
      );

      // Parse dates with multiple format support
      DateTime? parseDate(dynamic date) {
        if (date == null) return null;
        if (date is DateTime) return date;
        if (date is String) {
          try {
            return DateTime.parse(date);
          } catch (e) {
            try {
              return DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(date);
            } catch (e) {
              debugPrint('Failed to parse date: $date');
              return null;
            }
          }
        }
        return null;
      }

      // Parse last message - handles both ID and full message object
      Message? lastMessage;
      if (json['lastMessage'] is Map<String, dynamic>) {
        try {
          lastMessage = Message.fromJson(json['lastMessage']);
        } catch (e) {
          debugPrint('Failed to parse lastMessage: ${json['lastMessage']}');
        }
      }

      // Parse participant settings
      final participantSettings = <ParticipantSetting>[];
      if (json['participantSettings'] is List) {
        for (var setting in json['participantSettings']) {
          if (setting is Map<String, dynamic>) {
            try {
              participantSettings.add(ParticipantSetting.fromJson(setting));
            } catch (e) {
              debugPrint('Failed to parse participant setting: $setting');
            }
          }
        }
      }

      return Chat(
        id: parseString(json['_id'] ?? json['id']) ?? '',
        participants: participants,
        type: chatType,
        groupName: parseString(json['groupName']),
        groupDescription: parseString(json['groupDescription']),
        groupAdminId: parseString(json['groupAdminId'] ?? json['groupAdmin']),
        lastMessageId: json['lastMessage'] is String 
            ? parseString(json['lastMessage'])
            : parseString(json['lastMessage']?['_id']),
        lastMessage: lastMessage,
        lastActivity: parseDate(json['lastActivity']),
        isActive: json['isActive'] is bool ? json['isActive'] : true,
        pinnedMessages: (json['pinnedMessages'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ?? [],
        participantSettings: participantSettings,
        createdAt: parseDate(json['createdAt']),
        updatedAt: parseDate(json['updatedAt']),
        unreadCount: parseInt(json['unreadCount']) ?? 0,
        chatName: parseString(json['chatName']),
        chatImage: parseString(json['chatImage']),
        isOnline: parseBool(json['isOnline']),
        lastActive: parseDate(json['lastActive']),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing Chat: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'type': type.toString().split('.').last,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupAdminId': groupAdminId,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage?.toJson(),
      'lastActivity': lastActivity?.toIso8601String(),
      'isActive': isActive,
      'pinnedMessages': pinnedMessages,
      'participantSettings': participantSettings.map((ps) => ps.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'chatName': chatName,
      'chatImage': chatImage,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chat &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ParticipantSetting {
  final String userId;
  final bool isMuted;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String? lastReadMessageId;

  ParticipantSetting({
    required this.userId,
    this.isMuted = false,
    required this.joinedAt,
    this.leftAt,
    this.lastReadMessageId,
  });

  factory ParticipantSetting.fromJson(Map<String, dynamic> json) {
    try {
      DateTime? parseDate(dynamic date) {
        if (date == null) return null;
        if (date is DateTime) return date;
        if (date is String) {
          try {
            return DateTime.parse(date);
          } catch (e) {
            debugPrint('Failed to parse date: $date');
            return null;
          }
        }
        return null;
      }

      return ParticipantSetting(
        userId: json['user']?.toString() ?? json['userId']?.toString() ?? '',
        isMuted: json['isMuted'] is bool ? json['isMuted'] : false,
        joinedAt: parseDate(json['joinedAt']) ?? DateTime.now(),
        leftAt: parseDate(json['leftAt']),
        lastReadMessageId: json['lastReadMessage']?.toString() ?? 
                          json['lastReadMessageId']?.toString(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing ParticipantSetting: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isMuted': isMuted,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'lastReadMessageId': lastReadMessageId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantSetting &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}