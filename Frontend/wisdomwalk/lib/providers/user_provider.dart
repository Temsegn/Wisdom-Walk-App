import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class UserProvider with ChangeNotifier {
  final LocalStorageService _localStorageService;
  final List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  // Cache duration - 5 minutes
  static const Duration cacheDuration = Duration(minutes:5);
 
  // Correct constructor - only one parameter needed
  UserProvider({required LocalStorageService localStorageService})
      : _localStorageService = localStorageService;

  List<UserModel> get allUsers => List.unmodifiable(_allUsers);
  List<UserModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllUsers({bool forceRefresh = false}) async {
    // Return cached data if it's fresh and not forcing refresh
    if (!forceRefresh && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await _localStorageService.getAuthToken();
    if (token == null) {
      _error = 'Authentication required';
      _isLoading = false;
      notifyListeners();
      return;
    }

    const url = 'https://wisdom-walk-app.onrender.com/api/admin/users';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allUsers
          ..clear()
          ..addAll(data.map((e) => UserModel.fromJson(e)));
        _searchResults = List.from(_allUsers);
        _lastFetchTime = DateTime.now();

        debugPrint("Fetched ${_allUsers.length} users");
      } else {
        _error = 'Failed to fetch users: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      _error = 'Error fetching users: ${e.toString()}';
      debugPrint('Error in fetchAllUsers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchLocally(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    final lowerQuery = query.toLowerCase();
    _searchResults = _allUsers.where((user) {
      return (user.name?.toLowerCase().contains(lowerQuery) ?? false) ||
             user.email.toLowerCase().contains(lowerQuery) ||
             (user.fullName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    notifyListeners();
  }

  void clearSearch() {
    _searchResults = List.from(_allUsers);
    notifyListeners();
  }

  Future<bool> blockUser(String userId) async {
    final token = await _localStorageService.getAuthToken();
    if (token == null) return false;

    const url = 'https://wisdom-walk-app.onrender.com/api/admin/users/block';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        // Update the user's blocked status locally
        final index = _allUsers.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _allUsers[index] = _allUsers[index].copyWith(isBlocked: true);
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to block user: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error blocking user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}