class BookingRequest {
  final String issueTitle;
  final String issueDescription;
  final String userId;
  final DateTime createdAt;
  final String phoneNumber;
  final String email;
  final bool? virtualSession;

  BookingRequest({
    required this.issueTitle,
    required this.issueDescription,
    required this.userId,
    required this.createdAt,
    required this.phoneNumber,
    required this.email,
    this.virtualSession,
  });

  Map<String, dynamic> toJson() => {
        'issueTitle': issueTitle,
        'issueDescription': issueDescription,
        'user': userId, // Backend expects 'user' field
        'createdAt': createdAt.toIso8601String(),
        'phoneNumber': phoneNumber,
        'email': email,
        'virtualSession': virtualSession ?? false,
      };
}