import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/prayer_request.dart';
import 'package:wisdomwalk/utils/constants.dart';

class PrayerProvider with ChangeNotifier {
  List<PrayerRequest> _prayers = [];
  bool _isLoading = false;
  String? _error;

  List<PrayerRequest> get prayers => [..._prayers];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPrayers({String? filter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = '${Constants.apiUrl}/prayers';
      if (filter != null) {
        if (filter == 'My Prayers') {
          endpoint += '?mine=true';
        } else if (filter == 'Friends\' Prayers') {
          endpoint += '?friends=true';
        }
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> prayersJson = json.decode(response.body)['data'];
        _prayers = prayersJson.map((json) => PrayerRequest.fromJson(json)).toList();
      } else {
        _error = 'Failed to load prayers';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPrayer({
    required String content,
    required bool isAnonymous,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/prayers'),
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
        final newPrayer = PrayerRequest.fromJson(json.decode(response.body)['data']);
        _prayers.insert(0, newPrayer);
      } else {
        _error = 'Failed to create prayer';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> prayForRequest(String prayerId, String userId) async {
    try {
      // Optimistic update
      final prayerIndex = _prayers.indexWhere((prayer) => prayer.id == prayerId);
      if (prayerIndex != -1) {
        final prayer = _prayers[prayerIndex];
        final updatedPrayingUsers = List<String>.from(prayer.prayingUsers);
        
        if (!updatedPrayingUsers.contains(userId)) {
          updatedPrayingUsers.add(userId);
          
          final updatedPrayer = PrayerRequest(
            id: prayer.id,
            content: prayer.content,
            userId: prayer.userId,
            userFullName: prayer.userFullName,
            userProfilePicture: prayer.userProfilePicture,
            isAnonymous: prayer.isAnonymous,
            createdAt: prayer.createdAt,
            prayerCount: prayer.prayerCount + 1,
            prayingUsers: updatedPrayingUsers,
            comments: prayer.comments,
          );
          
          _prayers[prayerIndex] = updatedPrayer;
          notifyListeners();
        }
      }

      // Make API call
      await http.post(
        Uri.parse('${Constants.apiUrl}/prayers/$prayerId/pray'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
      // Revert optimistic update on error
      await fetchPrayers();
    }
  }

  Future<void> addComment(String prayerId, String content, bool isAnonymous) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/prayers/$prayerId/comments'),
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
        final newComment = PrayerComment.fromJson(json.decode(response.body)['data']);
        
        final prayerIndex = _prayers.indexWhere((prayer) => prayer.id == prayerId);
        if (prayerIndex != -1)  {
          final prayer = _prayers[prayerIndex];
          final updatedComments = List<PrayerComment>.from(prayer.comments)..add(newComment);
          
          final updatedPrayer = PrayerRequest(
            id: prayer.id,
            content: prayer.content,
            userId: prayer.userId,
            userFullName: prayer.userFullName,
            userProfilePicture: prayer.userProfilePicture,
            isAnonymous: prayer.isAnonymous,
            createdAt: prayer.createdAt,
            prayerCount: prayer.prayerCount,
            prayingUsers: prayer.prayingUsers,
            comments: updatedComments,
          );
          
          _prayers[prayerIndex] = updatedPrayer;
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
