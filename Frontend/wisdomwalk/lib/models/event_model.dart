// lib/models/event_model.dart
class EventModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final String platform;
  final String link; // e.g., Zoom or Telegram link
  final List<String> participants; // List of user IDs who joined
  final String description;

  EventModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.platform,
    required this.link,
    required this.participants,
    this.description = '',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      dateTime: DateTime.parse(
        json['dateTime'] ?? DateTime.now().toIso8601String(),
      ),
      platform: json['platform'] ?? '',
      link: json['link'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'platform': platform,
      'link': link,
      'participants': participants,
      'description': description,
    };
  }
}
