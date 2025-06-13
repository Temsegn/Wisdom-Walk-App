import 'package:wisdomwalk/models/user.dart';

class Post {
  final String id;
  final User author;
  final String content;
  final List<String> images;
  final List<String> likes;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String? groupType;
  final Map<String, dynamic>? scripture;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.images = const [],
    this.likes = const [],
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.groupType,
    this.scripture,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? json['id'] ?? '',
      author: User.fromJson(json['author']),
      content: json['content'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      likes: json['likes'] != null
          ? List<String>.from(json['likes'])
          : [],
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isPinned: json['isPinned'] ?? false,
      groupType: json['groupType'],
      scripture: json['scripture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'images': images,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'groupType': groupType,
      'scripture': scripture,
    };
  }

  Post copyWith({
    String? id,
    User? author,
    String? content,
    List<String>? images,
    List<String>? likes,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? groupType,
    Map<String, dynamic>? scripture,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      groupType: groupType ?? this.groupType,
      scripture: scripture ?? this.scripture,
    );
  }
}
