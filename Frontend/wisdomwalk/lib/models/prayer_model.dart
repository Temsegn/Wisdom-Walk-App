class PrayerModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final bool isAnonymous;
  final List<String> prayingUsers;
  final List<PrayerComment> comments;
  final DateTime createdAt;

  PrayerModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.isAnonymous = false,
    this.prayingUsers = const [],
    this.comments = const [],
    required this.createdAt,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      isAnonymous: json['isAnonymous'] ?? false,
      prayingUsers: List<String>.from(json['prayingUsers'] ?? []),
      comments:
          (json['comments'] as List?)
              ?.map((comment) => PrayerComment.fromJson(comment))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'isAnonymous': isAnonymous,
      'prayingUsers': prayingUsers,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PrayerComment {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final bool isAnonymous;
  final DateTime createdAt;

  PrayerComment({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.isAnonymous = false,
    required this.createdAt,
  });

  factory PrayerComment.fromJson(Map<String, dynamic> json) {
    return PrayerComment(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
