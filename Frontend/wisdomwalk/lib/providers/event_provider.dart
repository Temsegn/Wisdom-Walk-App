import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/event_model.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _baseUrl = 'https://wisdom-walk-app.onrender.com/api/events';

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final List<dynamic> data = responseBody['data'];
        _events = data.map((event) => EventModel.fromJson(event)).toList();
        _isLoading = false;
      } else {
        _error = responseBody['error'] ?? 'Failed to load events.';
        _isLoading = false;
      }
    } catch (e) {
      _error = 'Failed to fetch events: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<bool> toggleJoinEvent(String eventId, String userId) async {
    try {
      final index = _events.indexWhere((event) => event.id == eventId);
      if (index == -1) return false;

      final event = _events[index];
      final participants = [...event.participants];

      if (participants.contains(userId)) {
        participants.remove(userId);
      } else {
        participants.add(userId);
      }

      _events[index] = EventModel(
        id: event.id,
        title: event.title,
        dateTime: event.dateTime,
        platform: event.platform,
        link: event.link,
        participants: participants,
        description: event.description,
         duration: event.duration,
      );

      notifyListeners();

      // Optional: Add backend sync later

      return true;
    } catch (e) {
      _error = 'Failed to update event participation: $e';
      notifyListeners();
      return false;
    }
  }
}
