// lib/providers/event_provider.dart
import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/event_model.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Simulated backend call to fetch events
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Replace with actual API call (e.g., Firebase, REST API)
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      _events = [
        EventModel(
          id: 'event1',
          title: 'Virtual Prayer Night',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          platform: 'Zoom',
          link: 'https://zoom.us/j/123456789',
          participants: [],
          description: 'Join us for a night of prayer and fellowship.',
        ),
        EventModel(
          id: 'event2',
          title: 'Bible Study: Proverbs',
          dateTime: DateTime.now().add(const Duration(days: 4)),
          platform: 'Telegram',
          link: 'https://t.me/+soetKOhlubFhMWE0',
          participants: [],
          description: 'Explore the wisdom of Proverbs with our community.',
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch events: $e';
      notifyListeners();
    }
  }

  // Join or leave an event
  Future<bool> toggleJoinEvent(String eventId, String userId) async {
    try {
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex == -1) return false;

      final event = _events[eventIndex];
      final updatedParticipants = List<String>.from(event.participants);

      if (updatedParticipants.contains(userId)) {
        updatedParticipants.remove(userId); // Leave event
      } else {
        updatedParticipants.add(userId); // Join event
      }

      _events[eventIndex] = EventModel(
        id: event.id,
        title: event.title,
        dateTime: event.dateTime,
        platform: event.platform,
        link: event.link,
        participants: updatedParticipants,
        description: event.description,
      );

      notifyListeners();
      // Optionally, update backend here
      return true;
    } catch (e) {
      _error = 'Failed to update event participation: $e';
      notifyListeners();
      return false;
    }
  }
}
