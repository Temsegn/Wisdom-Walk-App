class Confession {
  final String id;
  final String content;
  final String category;
  final DateTime createdAt;
  final int heartCount;
  final List<String> heartUsers;
  final List<ConfessionComment> comments;

  Confession({
    required this.id,
    required this.content,
    required this.category,
    required this.createdAt,
    this.heartCount = 0,
    this.heartUsers = const [],
    this.comments = const [],
  });

  factory Confession.fromJson(Map<String, dynamic> json) {
    List<ConfessionComment> commentsList = [];
    if (json['comments'] != null) {
      commentsList = (json['comments'] as List)
          .map((comment) => ConfessionComment.fromJson(comment))
          .toList();
    }

    return Confession(
      id: json['_id'] ?? json['id'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'Confession',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      heartCount: json['heartCount'] ?? json['heartUsers']?.length ?? 0,
      heartUsers: json['heartUsers'] != null
          ? List<String>.from(json['heartUsers'])
          : [],
      comments: commentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'heartCount': heartCount,
      'heartUsers': heartUsers,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

class ConfessionComment {
  final String id;
  final String content;
  final String? userId;
  final String? userFullName;
  final String? userProfilePicture;
  final bool isAnonymous;
  final DateTime createdAt;
  final bool isReviewed;

  ConfessionComment({
    required this.id,
    required this.content,
    this.userId,
    this.userFullName,
    this.userProfilePicture,
    required this.isAnonymous,
    required this.createdAt,
    this.isReviewed = false,
  });

  factory ConfessionComment.fromJson(Map<String, dynamic> json) {
    return ConfessionComment(
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
      isReviewed: json['isReviewed'] ?? false,
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
      'isReviewed': isReviewed,
    };
  }
}
