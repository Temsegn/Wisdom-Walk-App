class Location {
  final String id;
  final String name;
  final String type; // 'church' or 'sister'
  final double latitude;
  final double longitude;
  final String address;
  final double? distance;
  final String? userId;
  final String? userFullName;
  final String? userProfilePicture;
  final String? churchName;
  final String? denomination;
  final String? website;
  final String? phoneNumber;
  final String? email;

  Location({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.distance,
    this.userId,
    this.userFullName,
    this.userProfilePicture,
    this.churchName,
    this.denomination,
    this.website,
    this.phoneNumber,
    this.email,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'church',
      latitude: json['latitude'] != null ? json['latitude'].toDouble() : 0.0,
      longitude: json['longitude'] != null ? json['longitude'].toDouble() : 0.0,
      address: json['address'] ?? '',
      distance: json['distance'] != null ? json['distance'].toDouble() : null,
      userId: json['userId'] ?? json['user']?['_id'],
      userFullName: json['userFullName'] ?? 
        (json['user'] != null 
          ? '${json['user']['firstName']} ${json['user']['lastName']}'
          : null),
      userProfilePicture: json['userProfilePicture'] ?? json['user']?['profilePicture'],
      churchName: json['churchName'],
      denomination: json['denomination'],
      website: json['website'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'distance': distance,
      'userId': userId,
      'userFullName': userFullName,
      'userProfilePicture': userProfilePicture,
      'churchName': churchName,
      'denomination': denomination,
      'website': website,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
