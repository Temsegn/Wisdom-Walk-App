class EventModel {
  final String id;
  final String title;
  final String description;
  final String platform;
  final DateTime dateTime;
  final String link; // meeting link
  final int duration;
  final List<String> participants;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.platform,
    required this.dateTime,
    required this.link,
    required this.duration,
    this.participants = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date'] ?? '') ?? DateTime.now();
    final timeString = json['time'] ?? '00:00';

    // Combine date and time
    final timeParts = timeString.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    return EventModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      platform: json['platform'] ?? '',
      dateTime: combinedDateTime,
      link: json['meetingLink'] ?? '',
      duration: json['duration'] ?? 0,
      participants: List<String>.from(json['participants'] ?? []), // future support
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'platform': platform,
      'date': dateTime.toIso8601String(),
      'time': '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
      'duration': duration,
      'meetingLink': link,
      'participants': participants,
    };
  }
}
