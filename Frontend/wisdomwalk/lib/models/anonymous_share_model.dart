enum AnonymousShareType { confession, testimony, struggle }

class AnonymousShareModel {
  final String id;
  final String userId;
  final String content;
  final AnonymousShareType type;
  final List<String> hearts;
  final List<AnonymousShareComment> comments;
  final List<String> prayingUsers;
  final List<String> virtualHugs;
  final DateTime createdAt;

  AnonymousShareModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.type,
    this.hearts = const [],
    this.comments = const [],
    this.prayingUsers = const [],
    this.virtualHugs = const [],
    required this.createdAt,
  });

  int get heartCount => hearts.length;
  int get prayerCount => prayingUsers.length;
  int get hugCount => virtualHugs.length;

  factory AnonymousShareModel.fromJson(Map<String, dynamic> json) {
    return AnonymousShareModel(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      type: AnonymousShareType.values.firstWhere(
        (e) => e.toString() == 'AnonymousShareType.${json['type']}',
        orElse: () => AnonymousShareType.confession,
      ),
      hearts: List<String>.from(json['hearts'] ?? []),
      comments:
          (json['comments'] as List?)
              ?.map((comment) => AnonymousShareComment.fromJson(comment))
              .toList() ??
          [],
      prayingUsers: List<String>.from(json['prayingUsers'] ?? []),
      virtualHugs: List<String>.from(json['virtualHugs'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'type': type.toString().split('.').last,
      'hearts': hearts,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'prayingUsers': prayingUsers,
      'virtualHugs': virtualHugs,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AnonymousShareComment {
  final String id;
  final String userId;
  final String content;
  final bool isModerated;
  final DateTime createdAt;

  AnonymousShareComment({
    required this.id,
    required this.userId,
    required this.content,
    this.isModerated = false,
    required this.createdAt,
    required String userName,
  });

  factory AnonymousShareComment.fromJson(Map<String, dynamic> json) {
    return AnonymousShareComment(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      isModerated: json['isModerated'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      userName: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'isModerated': isModerated,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
