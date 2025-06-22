import 'dart:io';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class AuthService {
  final LocalStorageService _localStorageService = LocalStorageService();

  // Mock data for demonstration
  final List<UserModel> _users = [
    UserModel(
      id: '1',
      fullName: 'Sarah Johnson',
      email: 'sarah@example.com',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      city: 'Addis Ababa',
      subcity: 'Bole',
      country: 'Ethiopia',
      wisdomCircleInterests: ['Marriage & Ministry', 'Mental Health & Faith'],
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String subcity,
    required String country,
    required String idImagePath,
    required String faceImagePath,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Check if email already exists
    if (_users.any((user) => user.email == email)) {
      throw Exception('Email already registered');
    }

    // Create new user
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      city: city,
      subcity: subcity,
      country: country,
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Add user to mock database
    _users.add(newUser);

    // Save auth token
    await _localStorageService.setAuthToken('mock_token_${newUser.id}');

    return newUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Find user by email
    final user = _users.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('Invalid email or password'),
    );

    // Save auth token
    await _localStorageService.setAuthToken('mock_token_${user.id}');

    return user;
  }

  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Find user by email
    final user = _users.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );

    // Update user verification status
    final index = _users.indexWhere((u) => u.id == user.id);
    _users[index] = user.copyWith(isVerified: true);

    // Save auth token
    await _localStorageService.setAuthToken('mock_token_${user.id}');

    return _users[index];
  }

  Future<void> resendOtp({required String email}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Check if email exists
    if (!_users.any((user) => user.email == email)) {
      throw Exception('Email not found');
    }

    // In a real app, this would send a new OTP to the user's email
  }

  Future<void> forgotPassword({required String email}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Check if email exists
    if (!_users.any((user) => user.email == email)) {
      throw Exception('Email not found');
    }

    // In a real app, this would send a password reset link to the user's email
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Check if email exists
    if (!_users.any((user) => user.email == email)) {
      throw Exception('Email not found');
    }

    // In a real app, this would verify the OTP and update the user's password
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? city,
    String? subcity,
    String? country,
    String? avatarPath,
    List<String>? wisdomCircleInterests,
    String? bio,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Find user by ID
    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      throw Exception('User not found');
    }

    // Update user profile
    final user = _users[index];
    String? avatarUrl;

    if (avatarPath != null) {
      // In a real app, this would upload the image to a storage service
      // and return the URL
      avatarUrl = 'https://randomuser.me/api/portraits/women/45.jpg';
    }

    _users[index] = user.copyWith(
      fullName: fullName ?? user.fullName,
      city: city ?? user.city,
      subcity: subcity ?? user.subcity,
      country: country ?? user.country,
      avatarUrl: avatarUrl ?? user.avatarUrl,
      wisdomCircleInterests:
          wisdomCircleInterests ?? user.wisdomCircleInterests,
      updatedAt: DateTime.now(),
    );

    return _users[index];
  }

  Future<UserModel> getCurrentUser() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would use the auth token to get the current user
    return _users.first;
  }

  Future<void> logout() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would invalidate the auth token on the server
  }
}
