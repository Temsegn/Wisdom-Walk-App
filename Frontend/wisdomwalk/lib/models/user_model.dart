import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String fullName; // Added as direct field
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String? city;
  final String? subcity;
  final String? country;
  final List<String> wisdomCircleInterests;
  final bool isVerified;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBlocked;

  UserModel({
    required this.id,
    String? fullName, // Optional fullName parameter
    this.firstName = '',
    this.lastName = '',
    required this.email,
    this.avatarUrl,
    this.city,
    this.subcity,
    this.country,
    this.wisdomCircleInterests = const [],
    this.isVerified = false,
    this.isOnline = false,
    required this.createdAt,
    required this.updatedAt,
    this.isBlocked = false,
  }) : fullName = fullName ?? [firstName, lastName].where((n) => n.isNotEmpty).join(' ');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle fullName from JSON or fallback to combining first/last names
      final jsonFullName = json['fullName']?.toString()?.trim() ?? '';
      final firstName = json['firstName']?.toString()?.trim() ?? '';
      final lastName = json['lastName']?.toString()?.trim() ?? '';
      
      return UserModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        fullName: jsonFullName.isNotEmpty ? jsonFullName : [firstName, lastName].where((n) => n.isNotEmpty).join(' '),
        firstName: firstName,
        lastName: lastName,
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        city: json['city']?.toString(),
        subcity: json['subcity']?.toString(),
        country: json['country']?.toString(),
        wisdomCircleInterests: List<String>.from(
          json['wisdomCircleInterests']?.map((x) => x.toString()) ?? [],
        ),
        isVerified: json['isVerified'] == true,
        isOnline: json['isOnline'] == true,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now(),
        isBlocked: json['isBlocked'] == true,
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
    final parts = fullName.split(' ');
    if (parts.isEmpty) return null;
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.trim().isNotEmpty ? '$first$last' : null;
  }

  DateTime? get lastActive => updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'firstName': firstName,
        'lastName': lastName,
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
        'isBlocked': isBlocked,
      };

  UserModel copyWith({
    String? id,
    String? fullName,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? city,
    String? subcity,
    String? country,
    List<String>? wisdomCircleInterests,
    bool? isVerified,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
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
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}