class PrayerModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final String? title; // Added to support title field
  final bool isAnonymous;
  final List<String> prayingUsers;
  final List<String> virtualHugUsers;
  final List<String> likedUsers;
  final int reportCount;
  final bool isReported;
  final List<PrayerComment> comments;
  final DateTime createdAt;

  PrayerModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.title,
    this.isAnonymous = false,
    this.prayingUsers = const [],
    this.virtualHugUsers = const [],
    this.likedUsers = const [],
    this.reportCount = 0,
    this.isReported = false,
    this.comments = const [],
    required this.createdAt,
  });

  factory PrayerModel.fromJson(Map<String, dynamic> json) {
    return PrayerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId:
          json['userId']?.toString() ??
          json['author']?['_id']?.toString() ??
          json['author']?.toString() ??
          '',
      userName:
          json['isAnonymous']
              ? null
              : json['userName'] ??
                  (json['author'] is Map
                      ? '${json['author']['firstName'] ?? ''} ${json['author']['lastName'] ?? ''}'
                          .trim()
                      : null),
      userAvatar:
          json['isAnonymous']
              ? null
              : json['userAvatar'] ?? json['author']?['profilePicture'],
      content: json['content']?.toString() ?? '',
      title: json['title'],
      isAnonymous: json['isAnonymous'] ?? false,
      prayingUsers: List<String>.from(
        json['prayingUsers'] ??
            json['prayers']?.map((p) => p['user']?.toString() ?? '') ??
            [],
      ),
      virtualHugUsers: List<String>.from(
        json['virtualHugUsers'] ??
            json['virtualHugs']?.map((h) => h['user']?.toString() ?? '') ??
            [],
      ),
      likedUsers: List<String>.from(
        json['likedUsers'] ??
            json['likes']?.map((l) => l['user']?.toString() ?? '') ??
            [],
      ),
      reportCount: json['reportCount'] ?? 0,
      isReported: json['isReported'] ?? false,
      comments:
          (json['comments'] as List?)
              ?.map((comment) => PrayerComment.fromJson(comment))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'title': title,
      'isAnonymous': isAnonymous,
      'prayingUsers': prayingUsers,
      'virtualHugUsers': virtualHugUsers,
      'likedUsers': likedUsers,
      'reportCount': reportCount,
      'isReported': isReported,
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
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId:
          json['userId']?.toString() ??
          json['author']?['_id']?.toString() ??
          json['author']?.toString() ??
          '',
      userName:
          json['isAnonymous']
              ? null
              : json['userName'] ??
                  (json['author'] is Map
                      ? '${json['author']['firstName']} ${json['author']['lastName']}'
                          .trim()
                      : null),
      userAvatar:
          json['isAnonymous']
              ? null
              : json['userAvatar'] ?? json['author']?['profilePicture'],
      content: json['content']?.toString() ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
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
