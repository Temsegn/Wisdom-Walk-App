class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? email;
  final String? profilePicture;
  final String? bio;
  final bool isOnline;
  final DateTime lastActive;
  final List<String> groups;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.email,
    this.profilePicture,
    this.bio,
    this.isOnline = false,
    required this.lastActive,
    this.groups = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : DateTime.now(),
      groups: json['groups'] != null
          ? List<String>.from(json['groups'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
      'groups': groups,
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? profilePicture,
    String? bio,
    bool? isOnline,
    DateTime? lastActive,
    List<String>? groups,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      groups: groups ?? this.groups,
    );
  }
}
