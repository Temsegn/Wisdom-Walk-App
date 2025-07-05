import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationRequestModel {
  final String? id; // Made nullable to handle null _id
  final String? userId; // Made nullable to handle null user
  final String? firstName; // Made nullable to handle null userName
  final String? lastName; // Made nullable to handle null userName
  final String? userAvatar;
  final String? fromCity;
  final String? fromCountry;
  final String? toCity; // Made nullable to handle null toLocation.city
  final String? toCountry; // Made nullable to handle null toLocation.country
  final String? description; // Made nullable to handle null note
  final DateTime? moveDate; // Made nullable to handle null movementDate
  final DateTime? createdAt; // Made nullable to handle null createdAt

  LocationRequestModel({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.userAvatar,
    this.fromCity,
    this.fromCountry,
    this.toCity,
    this.toCountry,
    this.description,
    this.moveDate,
    this.createdAt,
  });

  String get fromLocation =>
      fromCity != null && fromCountry != null
          ? '$fromCity, $fromCountry'
          : 'Current Location';
  String get toLocation =>
      toCity != null && toCountry != null ? '$toCity, $toCountry' : 'Unknown';
  DateTime get startDate => moveDate ?? DateTime.now();
  String get authorName =>
      (firstName != null && lastName != null)
          ? '$firstName $lastName'
          : firstName ?? 'Unknown';

  factory LocationRequestModel.fromJson(Map<String, dynamic> json) {
    return LocationRequestModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      userId:
          json['user'] is String
              ? json['user']?.toString()
              : json['user']?['_id']?.toString() ?? json['userId']?.toString(),
      firstName:
          json['user'] is Map
              ? json['user']['firstName']?.toString() ?? 'Unknown'
              : json['userName']?.toString() ?? 'Unknown',
      lastName:
          json['user'] is Map ? json['user']['lastName']?.toString() : null,
      userAvatar:
          json['user'] is Map
              ? json['user']['profilePicture']?.toString()
              : json['userAvatar']?.toString(),
      fromCity: json['fromLocation']?['city']?.toString(),
      fromCountry: json['fromLocation']?['country']?.toString(),
      toCity: json['toLocation']?['city']?.toString(),
      toCountry: json['toLocation']?['country']?.toString(),
      description: json['note']?.toString() ?? json['description']?.toString(),
      moveDate:
          json['movementDate'] != null
              ? DateTime.tryParse(json['movementDate']!.toString()) ??
                  DateTime.now()
              : DateTime.now(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt']!.toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'firstName': firstName,
      'userAvatar': userAvatar,
      'fromLocation': {'city': fromCity, 'country': fromCountry},
      'toLocation': {'city': toCity, 'country': toCountry},
      'note': description,
      'movementDate': moveDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
