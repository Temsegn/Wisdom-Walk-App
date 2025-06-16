class WisdomCircleModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int memberCount;
  final List<WisdomCircleMessage> messages;
  final List<String> pinnedMessages;
  final List<WisdomCircleEvent> events;

  WisdomCircleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.memberCount = 0,
    this.messages = const [],
    this.pinnedMessages = const [],
    this.events = const [],
  });

  factory WisdomCircleModel.fromJson(Map<String, dynamic> json) {
    return WisdomCircleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      memberCount: json['memberCount'] ?? 0,
      messages:
          (json['messages'] as List?)
              ?.map((message) => WisdomCircleMessage.fromJson(message))
              .toList() ??
          [],
      pinnedMessages: List<String>.from(json['pinnedMessages'] ?? []),
      events:
          (json['events'] as List?)
              ?.map((event) => WisdomCircleEvent.fromJson(event))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'memberCount': memberCount,
      'messages': messages.map((message) => message.toJson()).toList(),
      'pinnedMessages': pinnedMessages,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}

class WisdomCircleMessage {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final List<String> likes;

  WisdomCircleMessage({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likes = const [],
  });

  factory WisdomCircleMessage.fromJson(Map<String, dynamic> json) {
    return WisdomCircleMessage(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: List<String>.from(json['likes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }
}

class WisdomCircleEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String platform;
  final String link;

  WisdomCircleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.platform,
    required this.link,
  });

  factory WisdomCircleEvent.fromJson(Map<String, dynamic> json) {
    return WisdomCircleEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      platform: json['platform'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'platform': platform,
      'link': link,
    };
  }
}
