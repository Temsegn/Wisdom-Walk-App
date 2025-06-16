import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/services/wisdom_circle_service.dart';

class WisdomCircleProvider extends ChangeNotifier {
  final WisdomCircleService _wisdomCircleService = WisdomCircleService();

  List<WisdomCircleModel> _circles = [];
  WisdomCircleModel? _selectedCircle;
  bool _isLoading = false;
  String? _error;

  List<WisdomCircleModel> get circles => _circles;
  WisdomCircleModel? get selectedCircle => _selectedCircle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCircles() async {
    print('WisdomCircleProvider: Starting fetchCircles');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedCircles = await _wisdomCircleService.getWisdomCircles();
      _circles = fetchedCircles;
      print(
        'WisdomCircleProvider: Successfully fetched ${_circles.length} circles: ${_circles.map((c) => c.name).toList()}',
      );
    } catch (e) {
      _error = e.toString();
      _circles = []; // Reset on error
      print('WisdomCircleProvider: Error fetching circles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print(
        'WisdomCircleProvider: fetchCircles completed, isLoading: $_isLoading, circles: ${_circles.length}',
      );
    }
  }

  Future<void> fetchCircleDetails(String circleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCircle = await _wisdomCircleService.getWisdomCircleDetails(
        circleId,
      );
      print(
        'WisdomCircleProvider: Fetched details for circle: ${_selectedCircle?.name}',
      );
    } catch (e) {
      _error = e.toString();
      print('WisdomCircleProvider: Error fetching circle details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinCircle({
    required String circleId,
    required String userId,
  }) async {
    try {
      await _wisdomCircleService.joinCircle(circleId: circleId, userId: userId);

      // Update the circle member count
      final index = _circles.indexWhere((circle) => circle.id == circleId);
      if (index != -1) {
        _circles[index] = WisdomCircleModel(
          id: _circles[index].id,
          name: _circles[index].name,
          description: _circles[index].description,
          imageUrl: _circles[index].imageUrl,
          memberCount: _circles[index].memberCount + 1,
          messages: _circles[index].messages,
          pinnedMessages: _circles[index].pinnedMessages,
          events: _circles[index].events,
        );
      }

      if (_selectedCircle?.id == circleId) {
        _selectedCircle = WisdomCircleModel(
          id: _selectedCircle!.id,
          name: _selectedCircle!.name,
          description: _selectedCircle!.description,
          imageUrl: _selectedCircle!.imageUrl,
          memberCount: _selectedCircle!.memberCount + 1,
          messages: _selectedCircle!.messages,
          pinnedMessages: _selectedCircle!.pinnedMessages,
          events: _selectedCircle!.events,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('WisdomCircleProvider: Error joining circle: $e');
      return false;
    }
  }

  Future<bool> leaveCircle({
    required String circleId,
    required String userId,
  }) async {
    try {
      await _wisdomCircleService.leaveCircle(
        circleId: circleId,
        userId: userId,
      );

      // Update the circle member count
      final index = _circles.indexWhere((circle) => circle.id == circleId);
      if (index != -1) {
        _circles[index] = WisdomCircleModel(
          id: _circles[index].id,
          name: _circles[index].name,
          description: _circles[index].description,
          imageUrl: _circles[index].imageUrl,
          memberCount: _circles[index].memberCount - 1,
          messages: _circles[index].messages,
          pinnedMessages: _circles[index].pinnedMessages,
          events: _circles[index].events,
        );
      }

      if (_selectedCircle?.id == circleId) {
        _selectedCircle = WisdomCircleModel(
          id: _selectedCircle!.id,
          name: _selectedCircle!.name,
          description: _selectedCircle!.description,
          imageUrl: _selectedCircle!.imageUrl,
          memberCount: _selectedCircle!.memberCount - 1,
          messages: _selectedCircle!.messages,
          pinnedMessages: _selectedCircle!.pinnedMessages,
          events: _selectedCircle!.events,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('WisdomCircleProvider: Error leaving circle: $e');
      return false;
    }
  }

  Future<bool> sendMessage({
    required String circleId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
  }) async {
    try {
      final message = await _wisdomCircleService.sendMessage(
        circleId: circleId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        content: content,
      );

      if (_selectedCircle?.id == circleId) {
        final updatedMessages = List<WisdomCircleMessage>.from(
          _selectedCircle!.messages,
        )..add(message);

        _selectedCircle = WisdomCircleModel(
          id: _selectedCircle!.id,
          name: _selectedCircle!.name,
          description: _selectedCircle!.description,
          imageUrl: _selectedCircle!.imageUrl,
          memberCount: _selectedCircle!.memberCount,
          messages: updatedMessages,
          pinnedMessages: _selectedCircle!.pinnedMessages,
          events: _selectedCircle!.events,
        );

        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      print('WisdomCircleProvider: Error sending message: $e');
      return false;
    }
  }

  Future<bool> toggleLikeMessage({
    required String circleId,
    required String messageId,
    required String userId,
  }) async {
    try {
      if (_selectedCircle?.id != circleId) return false;

      final messageIndex = _selectedCircle!.messages.indexWhere(
        (m) => m.id == messageId,
      );
      if (messageIndex == -1) return false;

      final message = _selectedCircle!.messages[messageIndex];
      final isLiked = message.likes.contains(userId);

      List<String> updatedLikes;
      if (isLiked) {
        updatedLikes = List.from(message.likes)..remove(userId);
      } else {
        updatedLikes = List.from(message.likes)..add(userId);
      }

      await _wisdomCircleService.updateMessageLikes(
        circleId: circleId,
        messageId: messageId,
        likes: updatedLikes,
      );

      final updatedMessages = List<WisdomCircleMessage>.from(
        _selectedCircle!.messages,
      );
      updatedMessages[messageIndex] = WisdomCircleMessage(
        id: message.id,
        userId: message.userId,
        userName: message.userName,
        userAvatar: message.userAvatar,
        content: message.content,
        createdAt: message.createdAt,
        likes: updatedLikes,
      );

      _selectedCircle = WisdomCircleModel(
        id: _selectedCircle!.id,
        name: _selectedCircle!.name,
        description: _selectedCircle!.description,
        imageUrl: _selectedCircle!.imageUrl,
        memberCount: _selectedCircle!.memberCount,
        messages: updatedMessages,
        pinnedMessages: _selectedCircle!.pinnedMessages,
        events: _selectedCircle!.events,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('WisdomCircleProvider: Error toggling like: $e');
      return false;
    }
  }

  void clearSelectedCircle() {
    _selectedCircle = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
