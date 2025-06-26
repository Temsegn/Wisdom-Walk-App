class BookingRequest {
  final String category;
  final String description;
  final String? userId;
  final DateTime createdAt;
  final String? contact;
  final String? preferredMentor;
  final String? additionalNotes;
  final bool? virtualSession;
  final DateTime? date;
  final dynamic
  time; // TimeOfDay is not serializable, so keep as dynamic or String

  BookingRequest({
    required this.category,
    required this.description,
    this.userId,
    required this.createdAt,
    this.contact,
    this.preferredMentor,
    this.additionalNotes,
    this.virtualSession,
    this.date,
    this.time,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'description': description,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'contact': contact,
    'preferredMentor': preferredMentor,
    'additionalNotes': additionalNotes,
    'virtualSession': virtualSession,
    'date': date?.toIso8601String(),
    'time': time != null ? time.toString() : null,
  };
}
