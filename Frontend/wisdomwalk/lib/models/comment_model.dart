import 'package:wisdomwalk/models/user_model.dart';

class Comment {
  final String id;
  final String postId;
  final UserModel author;
  final String content;
  final String? parentCommentId;
  final List<String> replies;
  final List<CommentLike> likes;
  final bool isModerated;
  final String? moderatedById;
  final bool isHidden;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    this.parentCommentId,
    this.replies = const [],
    this.likes = const [],
    this.isModerated = false,
    this.moderatedById,
    this.isHidden = false,
    this.isReported = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      postId: json['post'] ?? '',
      author: UserModel.fromJson(json['author']),
      content: json['content'] ?? '',
      parentCommentId: json['parentComment'],
      replies: (json['replies'] as List<dynamic>?)?.cast<String>() ?? [],
      likes:
          (json['likes'] as List<dynamic>?)
              ?.map((e) => CommentLike.fromJson(e))
              .toList() ??
          [],
      isModerated: json['isModerated'] ?? false,
      moderatedById: json['moderatedBy'],
      isHidden: json['isHidden'] ?? false,
      isReported: json['isReported'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post': postId,
      'author': author.toJson(),
      'content': content,
      'parentComment': parentCommentId,
      'replies': replies,
      'likes': likes.map((e) => e.toJson()).toList(),
      'isModerated': isModerated,
      'moderatedBy': moderatedById,
      'isHidden': isHidden,
      'isReported': isReported,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CommentLike {
  final String userId;
  final DateTime createdAt;

  CommentLike({required this.userId, required this.createdAt});

  factory CommentLike.fromJson(Map<String, dynamic> json) {
    return CommentLike(
      userId: json['user'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': userId, 'createdAt': createdAt.toIso8601String()};
  }
}
