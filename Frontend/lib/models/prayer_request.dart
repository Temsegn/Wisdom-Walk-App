class PrayerRequest {
  final String id;
  final String content;
  final String? userId;
  final String? userFullName;
  final String? userProfilePicture;
  final bool isAnonymous;
  final DateTime createdAt;
  final int prayerCount;
  final List<String> prayingUsers;
  final List<PrayerComment> comments;

  PrayerRequest({
    required this.id,
    required this.content,
    this.userId,
    this.userFullName,
    this.userProfilePicture,
    required this.isAnonymous,
    required this.createdAt,
    this.prayerCount = 0,
    this.prayingUsers = const [],
    this.comments = const [],
  });

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    List<PrayerComment> commentsList = [];
    if (json['comments'] != null) {
      commentsList = (json['comments'] as List)
          .map((comment) => PrayerComment.fromJson(comment))
          .toList();
    }

    return PrayerRequest(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      userId: json['isAnonymous'] == true ? null : (json['userId'] ?? json['user']?['_id']),
      userFullName: json['isAnonymous'] == true
          ? null
          : json['userFullName'] ?? 
            (json['user'] != null 
              ? '${json['user']['firstName']} ${json['user']['lastName']}'
              : null),
      userProfilePicture: json['isAnonymous'] == true
          ? null
          : json['userProfilePicture'] ?? json['user']?['profilePicture'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      prayerCount: json['prayerCount'] ?? json['prayingUsers']?.length ?? 0,
      prayingUsers: json['prayingUsers'] != null
          ? List<String>.from(json['prayingUsers'])
          : [],
      comments: commentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'userFullName': userFullName,
      'userProfilePicture': userProfilePicture,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'prayerCount': prayerCount,
      'prayingUsers': prayingUsers,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

class PrayerComment {
  final String id;
  final String content;
  final String? userId;
  final String? userFullName;
  final String? userProfilePicture;
  final bool isAnonymous;
  final DateTime createdAt;

  PrayerComment({
    required this.id,
    required this.content,
    this.userId,
    this.userFullName,
    this.userProfilePicture,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory PrayerComment.fromJson(Map<String, dynamic> json) {
    return PrayerComment(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      userId: json['isAnonymous'] == true ? null : (json['userId'] ?? json['user']?['_id']),
      userFullName: json['isAnonymous'] == true
          ? null
          : json['userFullName'] ?? 
            (json['user'] != null 
              ? '${json['user']['firstName']} ${json['user']['lastName']}'
              : null),
      userProfilePicture: json['isAnonymous'] == true
          ? null
          : json['userProfilePicture'] ?? json['user']?['profilePicture'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'userFullName': userFullName,
      'userProfilePicture': userProfilePicture,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
