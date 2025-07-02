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
  final DateTime lastActivity;
  final bool isActive;
  final List<String> pinnedMessages;
  final List<ParticipantSetting> participantSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final String? chatName;
  final String? chatImage;
  final bool? isOnline;

  Chat({
    required this.id,
    required this.participants,
    this.type = ChatType.direct,
    this.groupName,
    this.groupDescription,
    this.groupAdminId,
    this.lastMessageId,
    this.lastMessage,
    required this.lastActivity,
    this.isActive = true,
    this.pinnedMessages = const [],
    this.participantSettings = const [],
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.chatName,
    this.chatImage,
    this.isOnline,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => UserModel.fromJson(e))
          .toList() ?? [],
      type: ChatType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatType.direct,
      ),
      groupName: json['groupName'],
      groupDescription: json['groupDescription'],
      groupAdminId: json['groupAdmin'],
      lastMessageId: json['lastMessage'] is String ? json['lastMessage'] : null,
      lastMessage: json['lastMessage'] is Map 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      lastActivity: DateTime.parse(json['lastActivity']),
      isActive: json['isActive'] ?? true,
      pinnedMessages: (json['pinnedMessages'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      participantSettings: (json['participantSettings'] as List<dynamic>?)
          ?.map((e) => ParticipantSetting.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      unreadCount: json['unreadCount'] ?? 0,
      chatName: json['chatName'],
      chatImage: json['chatImage'],
      isOnline: json['isOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((e) => e.toJson()).toList(),
      'type': type.name,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupAdmin': groupAdminId,
      'lastMessage': lastMessageId,
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
      'pinnedMessages': pinnedMessages,
      'participantSettings': participantSettings.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'unreadCount': unreadCount,
      'chatName': chatName,
      'chatImage': chatImage,
      'isOnline': isOnline,
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
    return ParticipantSetting(
      userId: json['user'] ?? '',
      isMuted: json['isMuted'] ?? false,
      joinedAt: DateTime.parse(json['joinedAt']),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      lastReadMessageId: json['lastReadMessage'],
    );
  }

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
