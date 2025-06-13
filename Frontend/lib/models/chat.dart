import 'package:wisdomwalk/models/user.dart';

class Chat {
  final String id;
  final String type;
  final List<User> participants;
  final DateTime createdAt;
  final DateTime lastActivity;
  final String? lastMessageId;
  final int unreadCount;
  final Map<String, dynamic>? groupInfo;

  Chat({
    required this.id,
    required this.type,
    required this.participants,
    required this.createdAt,
    required this.lastActivity,
    this.lastMessageId,
    this.unreadCount = 0,
    this.groupInfo,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    List<User> participants = [];
    if (json['participants'] != null) {
      participants = (json['participants'] as List)
          .map((user) => User.fromJson(user))
          .toList();
    }

    return Chat(
      id: json['_id'],
      type: json['type'],
      participants: participants,
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      lastMessageId: json['lastMessage'],
      unreadCount: json['unreadCount'] ?? 0,
      groupInfo: json['groupInfo'],
    );
  }

  // Get chat name (for direct chats, use the other participant's name)
  String getChatName(String currentUserId) {
    if (type == 'direct') {
      final otherParticipant = participants.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.fullName;
    } else {
      return groupInfo?['name'] ?? 'Group Chat';
    }
  }

  // Get chat image (for direct chats, use the other participant's profile picture)
  String? getChatImage(String currentUserId) {
    if (type == 'direct') {
      final otherParticipant = participants.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.profilePicture;
    } else {
      return groupInfo?['image']; // Group chats don't have images in this example
    }
  }
}
