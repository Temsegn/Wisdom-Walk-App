import 'package:flutter/foundation.dart';
import 'user_model.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final String? parentCommentId;
  final List<String> replies;
  final List<CommentLike> likes;
  final bool isModerated;
  final String? moderatedBy;
  final bool isHidden;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? author; // Populated author info

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.parentCommentId,
    required this.replies,
    required this.likes,
    required this.isModerated,
    this.moderatedBy,
    required this.isHidden,
    required this.isReported,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      postId: json['post'],
      authorId: json['author'],
      content: json['content'],
      parentCommentId: json['parentComment'],
      replies: List<String>.from(json['replies'] ?? []),
      likes: (json['likes'] as List)
          .map((e) => CommentLike.fromJson(e))
          .toList(),
      isModerated: json['isModerated'] ?? false,
      moderatedBy: json['moderatedBy'],
      isHidden: json['isHidden'] ?? false,
      isReported: json['isReported'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: json['author'] != null ? UserModel.fromJson(json['author']) : null,
    );
  }

  int get likeCount => likes.length;
  bool get isReply => parentCommentId != null;
}

class CommentLike {
  final String userId;
  final DateTime createdAt;

  CommentLike({
    required this.userId,
    required this.createdAt,
  });

  factory CommentLike.fromJson(Map<String, dynamic> json) {
    return CommentLike(
      userId: json['user'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}