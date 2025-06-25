class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? city;
  final String? subcity;
  final String? country;
  final List<String> wisdomCircleInterests;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.city,
    this.subcity,
    this.country,
    this.wisdomCircleInterests = const [],
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      city: json['city'],
      subcity: json['subcity'],
      country: json['country'],
      wisdomCircleInterests: List<String>.from(
        json['wisdomCircleInterests'] ?? [],
      ),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  get name => null;

  get profilePicture => null;

  get avatar => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'city': city,
      'subcity': subcity,
      'country': country,
      'wisdomCircleInterests': wisdomCircleInterests,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? city,
    String? subcity,
    String? country,
    List<String>? wisdomCircleInterests,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      subcity: subcity ?? this.subcity,
      country: country ?? this.country,
      wisdomCircleInterests:
          wisdomCircleInterests ?? this.wisdomCircleInterests,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
