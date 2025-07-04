enum AnonymousShareType { confession, testimony, struggle }

class AnonymousShareModel {
  final String id;
  final String userId; // author
  final String content;
  final AnonymousShareType? category; // testimony, confession, struggle
  final String? title;
  final List<Map<String, String>> images; // url, caption
  final bool isAnonymous;
  final List<String> likes; // user IDs
  final List<Map<String, dynamic>> prayers; // user ID, message, createdAt
  final List<Map<String, dynamic>> virtualHugs; // user ID, scripture, createdAt
  final int commentsCount;
  final List<AnonymousShareComment> comments;
  final bool isReported;
  final int reportCount;
  final bool isHidden;
  final List<String> tags;
  final DateTime? scheduledFor;
  final bool isPublished;
  final DateTime createdAt;

  AnonymousShareModel({
    required this.id,
    required this.userId,
    required this.content,
    this.category,
    this.title,
    this.images = const [],
    this.isAnonymous = false,
    this.likes = const [],
    this.prayers = const [],
    this.virtualHugs = const [],
    this.commentsCount = 0,
    this.comments = const [],
    this.isReported = false,
    this.reportCount = 0,
    this.isHidden = false,
    this.tags = const [],
    this.scheduledFor,
    this.isPublished = true,
    required this.createdAt,
  });

  int get heartCount => likes.length;
  int get prayerCount => prayers.length;
  int get hugCount => virtualHugs.length;

  factory AnonymousShareModel.fromJson(Map<dynamic, dynamic> json) {
    return AnonymousShareModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId:
          json['author'] is Map
              ? json['author']['_id']?.toString() ?? ''
              : json['author']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category:
          json['category'] != null && json['category'].isNotEmpty
              ? AnonymousShareType.values.firstWhere(
                (e) => e.toString() == 'AnonymousShareType.${json['category']}',
                orElse: () => AnonymousShareType.confession,
              )
              : null,
      title: json['title']?.toString(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map(
                (img) => {
                  'url': img['url']?.toString() ?? '',
                  'caption': img['caption']?.toString() ?? '',
                },
              )
              .toList() ??
          [],
      isAnonymous: json['isAnonymous'] ?? false,
      likes:
          (json['likes'] as List<dynamic>?)
              ?.map((like) => like['user']?.toString() ?? '')
              .toList() ??
          [],
      prayers:
          (json['prayers'] as List<dynamic>?)
              ?.map(
                (prayer) => {
                  'user': prayer['user']?.toString() ?? '',
                  'message': prayer['message']?.toString() ?? '',
                  'createdAt': DateTime.parse(
                    prayer['createdAt']?.toString() ??
                        DateTime.now().toIso8601String(),
                  ),
                },
              )
              .toList() ??
          [],
      virtualHugs:
          (json['virtualHugs'] as List<dynamic>?)
              ?.map(
                (hug) => {
                  'user': hug['user']?.toString() ?? '',
                  'scripture': hug['scripture']?.toString() ?? '',
                  'createdAt': DateTime.parse(
                    hug['createdAt']?.toString() ??
                        DateTime.now().toIso8601String(),
                  ),
                },
              )
              .toList() ??
          [],
      commentsCount: json['commentsCount'] ?? 0,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((comment) => AnonymousShareComment.fromJson(comment))
              .toList() ??
          [],
      isReported: json['isReported'] ?? false,
      reportCount: json['reportCount'] ?? 0,
      isHidden: json['isHidden'] ?? false,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag.toString())
              .toList() ??
          [],
      scheduledFor:
          json['scheduledFor'] != null
              ? DateTime.parse(json['scheduledFor'])
              : null,
      isPublished: json['isPublished'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': userId,
      'content': content,
      'category': category?.toString().split('.').last,
      'title': title,
      'images': images,
      'isAnonymous': isAnonymous,
      'likes': likes.map((userId) => {'user': userId}).toList(),
      'prayers': prayers,
      'virtualHugs': virtualHugs,
      'commentsCount': commentsCount,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'isReported': isReported,
      'reportCount': reportCount,
      'isHidden': isHidden,
      'tags': tags,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'isPublished': isPublished,
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
  final String? userName;

  AnonymousShareComment({
    required this.id,
    required this.userId,
    required this.content,
    this.isModerated = false,
    required this.createdAt,
    this.userName,
  });

  factory AnonymousShareComment.fromJson(Map<String, dynamic> json) {
    return AnonymousShareComment(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['author']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isModerated: json['isModerated'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      userName: json['userName']?.toString() ?? 'Anonymous Sister',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'content': content,
      'isModerated': isModerated,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
    };
  }
}
