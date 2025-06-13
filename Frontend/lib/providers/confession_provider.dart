import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/confession.dart';
import 'package:wisdomwalk/utils/constants.dart';

class ConfessionProvider with ChangeNotifier {
  List<Confession> _confessions = [];
  List<Confession> _filteredConfessions = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;

  List<Confession> get confessions => _selectedCategory == null 
      ? [..._confessions] 
      : [..._filteredConfessions];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  Future<void> fetchConfessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/confessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> confessionsJson = json.decode(response.body)['data'];
        _confessions = confessionsJson.map((json) => Confession.fromJson(json)).toList();
        
        if (_selectedCategory != null) {
          _filterConfessions();
        }
      } else {
        _error = 'Failed to load confessions';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    if (category != null) {
      _filterConfessions();
    }
    notifyListeners();
  }

  void _filterConfessions() {
    _filteredConfessions = _confessions
        .where((confession) => confession.category == _selectedCategory)
        .toList();
  }

  Future<void> createConfession({
    required String content,
    required String category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/confessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
        body: json.encode({
          'content': content,
          'category': category,
        }),
      );

      if (response.statusCode == 201) {
        final newConfession = Confession.fromJson(json.decode(response.body)['data']);
        _confessions.insert(0, newConfession);
        
        if (_selectedCategory != null) {
          _filterConfessions();
        }
      } else {
        _error = 'Failed to create confession';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHeart(String confessionId, String userId) async {
    try {
      // Optimistic update
      final confessionIndex = _confessions.indexWhere((confession) => confession.id == confessionId);
      if (confessionIndex != -1) {
        final confession = _confessions[confessionIndex];
        final updatedHeartUsers = List<String>.from(confession.heartUsers);
        
        if (!updatedHeartUsers.contains(userId)) {
          updatedHeartUsers.add(userId);
          
          final updatedConfession = Confession(
            id: confession.id,
            content: confession.content,
            category: confession.category,
            createdAt: confession.createdAt,
            heartCount: confession.heartCount + 1,
            heartUsers: updatedHeartUsers,
            comments: confession.comments,
          );
          
          _confessions[confessionIndex] = updatedConfession;
          
          if (_selectedCategory != null) {
            _filterConfessions();
          }
          
          notifyListeners();
        }
      }

      // Make API call
      await http.post(
        Uri.parse('${Constants.apiUrl}/confessions/$confessionId/heart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      // Revert optimistic update on error
      await fetchConfessions();
    }
  }

  Future<void> addComment(String confessionId, String content, bool isAnonymous) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/confessions/$confessionId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
        body: json.encode({
          'content': content,
          'isAnonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 201) {
        final newComment = ConfessionComment.fromJson(json.decode(response.body)['data']);
        
        final confessionIndex = _confessions.indexWhere((confession) => confession.id == confessionId);
        if (confessionIndex != -1)  {
          final confession = _confessions[confessionIndex];
          final updatedComments = List<ConfessionComment>.from(confession.comments)..add(newComment);
          
          final updatedConfession = Confession(
            id: confession.id,
            content: confession.content,
            category: confession.category,
            createdAt: confession.createdAt,
            heartCount: confession.heartCount,
            heartUsers: confession.heartUsers,
            comments: updatedComments,
          );
          
          _confessions[confessionIndex] = updatedConfession;
          
          if (_selectedCategory != null) {
            _filterConfessions();
          }
          
          notifyListeners();
        }
      } else {
        _error = 'Failed to add comment';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
    }
  }
}
