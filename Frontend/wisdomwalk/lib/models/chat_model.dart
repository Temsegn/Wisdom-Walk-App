import 'package:flutter/foundation.dart';
import 'message_model.dart';
import 'user_model.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String type; // 'direct' or 'group'
  final String? groupName;
  final String? groupDescription;
  final String? groupAdmin;
  final String? lastMessageId;
  final DateTime lastActivity;
  final bool isActive;
  final List<String> pinnedMessages;
  final List<ParticipantSettings> participantSettings;
  final int unreadCount;
  final UserModel? otherParticipant; // For direct chats
  final Message? lastMessage;

  Chat({
    required this.id,
    required this.participants,
    required this.type,
    this.groupName,
    this.groupDescription,
    this.groupAdmin,
    this.lastMessageId,
    required this.lastActivity,
    required this.isActive,
    required this.pinnedMessages,
    required this.participantSettings,
    this.unreadCount = 0,
    this.otherParticipant,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json, {UserModel? currentUser}) {
    final otherParticipant = json['otherParticipant'] != null
        ? UserModel.fromJson(json['otherParticipant'])
        : null;

    return Chat(
      id: json['_id'],
      participants: List<String>.from(json['participants']),
      type: json['type'],
      groupName: json['groupName'],
      groupDescription: json['groupDescription'],
      groupAdmin: json['groupAdmin'],
      lastMessageId: json['lastMessage'],
      lastActivity: DateTime.parse(json['lastActivity']),
      isActive: json['isActive'],
      pinnedMessages: List<String>.from(json['pinnedMessages'] ?? []),
      participantSettings: (json['participantSettings'] as List)
          .map((e) => ParticipantSettings.fromJson(e))
          .toList(),
      unreadCount: json['unreadCount'] ?? 0,
      otherParticipant: otherParticipant,
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
    );
  }

  String get displayName {
    if (type == 'group') {
      return groupName ?? 'Group Chat';
    }
    return "otherParticipant?.displayName ?? participants[0]";
  }

  String? get displayImage {
    if (type == 'group') {
      return null; // Use a group icon or first letter
    }
    return otherParticipant?.profilePicture;
  }

  bool get isMuted {
    final currentUserId = otherParticipant?.id;
    if (currentUserId == null) return false;
    
    final settings = participantSettings.firstWhere(
      (s) => s.userId == currentUserId,
      orElse: () => ParticipantSettings(
        userId: currentUserId,
        isMuted: false,
        joinedAt: DateTime.now(),
      ),
    );
    return settings.isMuted;
  }

  String get lastActivityFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}m';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}

class ParticipantSettings {
  final String userId;
  final bool isMuted;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String? lastReadMessageId;

  ParticipantSettings({
    required this.userId,
    required this.isMuted,
    required this.joinedAt,
    this.leftAt,
    this.lastReadMessageId,
  });

  factory ParticipantSettings.fromJson(Map<String, dynamic> json) {
    return ParticipantSettings(
      userId: json['user'],
      isMuted: json['isMuted'] ?? false,
      joinedAt: DateTime.parse(json['joinedAt']),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      lastReadMessageId: json['lastReadMessage'],
    );
  }
}