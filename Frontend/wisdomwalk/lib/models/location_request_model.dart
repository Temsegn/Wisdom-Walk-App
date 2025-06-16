class LocationRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String city;
  final String country;
  final String description;
  final DateTime moveDate;
  final List<LocationResponse> responses;
  final DateTime createdAt;

  LocationRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.city,
    required this.country,
    required this.description,
    required this.moveDate,
    this.responses = const [],
    required this.createdAt,
  });

  // Add getter methods for the missing properties
  String get fromLocation =>
      'Current Location'; // You can modify this based on your needs
  String get toLocation => '$city, $country';
  DateTime get startDate => moveDate;
  String get authorName => userName;

  factory LocationRequestModel.fromJson(Map<String, dynamic> json) {
    return LocationRequestModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      city: json['city'],
      country: json['country'],
      description: json['description'],
      moveDate: DateTime.parse(json['moveDate']),
      responses:
          (json['responses'] as List?)
              ?.map((response) => LocationResponse.fromJson(response))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'city': city,
      'country': country,
      'description': description,
      'moveDate': moveDate.toIso8601String(),
      'responses': responses.map((response) => response.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class LocationResponse {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final String contactInfo;
  final bool isChurch;
  final String? churchName;
  final String? churchAddress;
  final String? churchWebsite;
  final DateTime createdAt;

  LocationResponse({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.contactInfo = '',
    this.isChurch = false,
    this.churchName,
    this.churchAddress,
    this.churchWebsite,
    required this.createdAt,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      contactInfo: json['contactInfo'] ?? '',
      isChurch: json['isChurch'] ?? false,
      churchName: json['churchName'],
      churchAddress: json['churchAddress'],
      churchWebsite: json['churchWebsite'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'contactInfo': contactInfo,
      'isChurch': isChurch,
      'churchName': churchName,
      'churchAddress': churchAddress,
      'churchWebsite': churchWebsite,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
