import 'package:flutter/foundation.dart';

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
  final bool isOnline; // Changed from getter to final field
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
    this.isOnline = false, // Default to false
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        city: json['city']?.toString(),
        subcity: json['subcity']?.toString(),
        country: json['country']?.toString(),
        wisdomCircleInterests: List<String>.from(
          json['wisdomCircleInterests']?.map((x) => x.toString()) ?? [],
        ),
        isVerified: json['isVerified'] == true,
        isOnline: json['isOnline'] == true, // Parse from JSON
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing UserModel: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Problematic JSON: $json');
      return UserModel.empty();
    }
  }

  static UserModel empty() => UserModel(
        id: '',
        fullName: 'Unknown',
        email: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Getters
  String? get name => fullName.isNotEmpty ? fullName : null;
  String? get profilePicture => avatarUrl;
  String? get avatar => avatarUrl;
  String get displayName => fullName.isNotEmpty ? fullName : 'Unknown User';
String? get initials {
    if (fullName.isEmpty) return null;
    
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return null;
    
    // Get first character of first name
    String initials = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    
    // Get first character of last name if exists
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }
    
    return initials.isNotEmpty ? initials : null;
  }
  DateTime? get lastActive => updatedAt;
  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'avatarUrl': avatarUrl,
        'city': city,
        'subcity': subcity,
        'country': country,
        'wisdomCircleInterests': wisdomCircleInterests,
        'isVerified': isVerified,
        'isOnline': isOnline,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

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
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt, required bool isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      subcity: subcity ?? this.subcity,
      country: country ?? this.country,
      wisdomCircleInterests: wisdomCircleInterests ?? this.wisdomCircleInterests,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}