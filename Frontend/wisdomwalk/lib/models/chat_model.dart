import 'package:flutter/foundation.dart';

import 'user_model.dart';
import 'message_model.dart';

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
      // Parse participants safely
      final participants =
          (json['participants'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => UserModel.fromJson(e))
              .toList() ??
          [];

      // Parse last message safely
      Message? lastMessage;
      if (json['lastMessage'] is Map<String, dynamic>) {
        try {
          lastMessage = Message.fromJson(json['lastMessage']);
        } catch (e) {
          debugPrint('Error parsing lastMessage: $e');
        }
      }

      // Parse dates safely
      DateTime? parseDate(dynamic date) {
        if (date is String) return DateTime.tryParse(date);
        return null;
      }

      return Chat(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        participants: participants,
        type: ChatType.values.firstWhere(
          (e) => e.toString().split('.').last == (json['type'] ?? 'direct'),
          orElse: () => ChatType.direct,
        ),
        groupName: json['groupName']?.toString(),
        groupDescription: json['groupDescription']?.toString(),
        groupAdminId:
            json['groupAdmin']?.toString() ?? json['groupAdminId']?.toString(),
        lastMessageId:
            json['lastMessage'] is String
                ? json['lastMessage']?.toString()
                : null,
        lastMessage: lastMessage,
        lastActivity: parseDate(json['lastActivity']),
        isActive: json['isActive'] is bool ? json['isActive'] : true,
        pinnedMessages:
            (json['pinnedMessages'] as List<dynamic>?)
                ?.whereType<String>()
                .toList() ??
            [],
        participantSettings:
            (json['participantSettings'] as List<dynamic>?)
                ?.map((e) => ParticipantSetting.fromJson(e))
                .toList() ??
            [],
        createdAt: parseDate(json['createdAt']),
        updatedAt: parseDate(json['updatedAt']),
        unreadCount: (json['unreadCount'] is int) ? json['unreadCount'] : 0,
        chatName: json['chatName']?.toString(),
        chatImage: json['chatImage']?.toString(),
        isOnline: json['isOnline'] is bool ? json['isOnline'] : null,
        lastActive: parseDate(json['lastActive']),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing Chat: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Problematic JSON: $json');
      rethrow;
    }
  }

  // ... toJson() method ...
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'type': type.toString().split('.').last,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupAdmin': groupAdminId,
      'lastMessage': lastMessageId ?? lastMessage?.toJson(),
      'lastActivity': lastActivity?.toIso8601String(),
      'isActive': isActive,
      'pinnedMessages': pinnedMessages,
      'participantSettings':
          participantSettings.map((ps) => ps.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'chatName': chatName,
      'chatImage': chatImage,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
    };
  }
}

enum ChatType { direct, group }

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
        if (date is String) return DateTime.tryParse(date);
        return null;
      }

      return ParticipantSetting(
        userId: json['user']?.toString() ?? '',
        isMuted: json['isMuted'] is bool ? json['isMuted'] : false,
        joinedAt: parseDate(json['joinedAt']) ?? DateTime.now(),
        leftAt: parseDate(json['leftAt']),
        lastReadMessageId: json['lastReadMessage']?.toString(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing ParticipantSetting: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ... toJson() method ...
  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'isMuted': isMuted,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'lastReadMessage': lastReadMessageId,
    };
  }
}
