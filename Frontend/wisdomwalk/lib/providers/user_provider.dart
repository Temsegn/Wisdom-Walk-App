import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
class UserProvider with ChangeNotifier {
  
  final LocalStorageService _localStorageService = LocalStorageService();

    
  final List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get allUsers => List.unmodifiable(_allUsers);
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
Future<void> fetchAllUsers( ) async {
  _isLoading = true;
  _error = null;
  notifyListeners();
      final token =await _localStorageService.getAuthToken();

  final url = Uri.parse('https://wisdom-walk-app.onrender.com/api/admin/users');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _allUsers
        ..clear()
        ..addAll(data.map((e) => UserModel.fromJson(e)).toList());
      _searchResults = List.from(_allUsers);

      // DEBUG print
      print("Fetched ${_allUsers.length} users");
    } else {
      _error = 'Failed to fetch users: ${response.statusCode}';
    }
  } catch (e) {
    _error = 'Error: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// Local filtering from previously fetched users
  void searchLocally(String query) {
    final lowerQuery = query.toLowerCase();

    _searchResults = _allUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery);
    }).toList();

    notifyListeners();
  }

  /// Reset search
  void clearSearch() {
    _searchResults = List.from(_allUsers);
    notifyListeners();
  }
}
