import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final List<UserModel> _allUsers = []; // Fetched from backend or Firestore
  List<UserModel> _searchResults = [];

  List<UserModel> get searchResults => _searchResults;

  Future<void> loadUsers(List<UserModel> users) async {
    _allUsers.clear();
    _allUsers.addAll(users);
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    final lowercaseQuery = query.toLowerCase();

    _searchResults = _allUsers.where((user) {
      return user.name.toLowerCase().contains(lowercaseQuery) ||
             user.email.toLowerCase().contains(lowercaseQuery);
    }).toList();

    notifyListeners();
  }

  void clearSearch() {
    _searchResults.clear();
    notifyListeners();
  }
}
