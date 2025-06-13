import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdomwalk/models/location.dart';
import 'package:wisdomwalk/utils/constants.dart';

class LocationProvider with ChangeNotifier {
  List<Location> _locations = [];
  bool _isLoading = false;
  String? _error;

  List<Location> get locations => [..._locations];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recentLocationSearches') ?? [];
      return searches;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRecentSearch(String search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recentLocationSearches') ?? [];
      
      if (!searches.contains(search)) {
        searches.insert(0, search);
        if (searches.length > 5) {
          searches.removeRange(5, searches.length);
        }
        await prefs.setStringList('recentLocationSearches', searches);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<Location>> searchLocation(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/locations/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> locationsJson = json.decode(response.body)['data'];
        _locations = locationsJson.map((json) => Location.fromJson(json)).toList();
        return _locations;
      } else {
        _error = 'Failed to search locations';
        return [];
      }
    } catch (e) {
      _error = 'Network error: $e';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createLocationPost({
    required String location,
    required String content,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
        body: json.encode({
          'content': content,
          'location': location,
          'type': 'location_help',
        }),
      );

      if (response.statusCode != 201) {
        _error = 'Failed to create location post';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> connectWithChurch(String churchId) async {
    try {
      await http.post(
        Uri.parse('${Constants.apiUrl}/locations/churches/$churchId/connect'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
    }
  }

  Future<void> connectWithSister(String userId) async {
    try {
      await http.post(
        Uri.parse('${Constants.apiUrl}/users/$userId/connect'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.authToken}',
        },
      );
    } catch (e) {
      _error = 'Network error: $e';
      notifyListeners();
    }
  }
}
