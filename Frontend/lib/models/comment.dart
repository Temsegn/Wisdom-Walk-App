import 'package:wisdomwalk/models/user.dart';

class Comment {
  final String id;
  final User user;
  final String content;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.user,
    required this.content,
    this.likes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      user: User.fromJson(json['user']),
      content: json['content'] ?? '',
      likes: json['likes'] != null
          ? List<String>.from(json['likes'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'content': content,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    User? user,
    String? content,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
