import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/services/wisdom_circle_service.dart';

class WisdomCircleProvider extends ChangeNotifier {
  final WisdomCircleService _wisdomCircleService = WisdomCircleService();
  final Set<String> _joinedCircles = {'1', '3'};
  List<WisdomCircleModel> _circles = [];
  WisdomCircleModel? _selectedCircle;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WisdomCircleModel> get circles => _circles;
  Set<String> get joinedCircles => _joinedCircles;
  WisdomCircleModel? get selectedCircle => _selectedCircle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WisdomCircleProvider() {
    _initializeWithMockData();
  }

  void _initializeWithMockData() {
    _circles = [
      WisdomCircleModel(
        id: '1',
        name: 'Single & Purposeful',
        description:
            'A supportive community for single women walking in their God-given purpose.',
        imageUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=300&fit=crop',
        memberCount: 127,
        messages: [],
        pinnedMessages: [],
        events: [],
      ),
      WisdomCircleModel(
        id: '2',
        name: 'Marriage & Ministry',
        description:
            'Navigating the beautiful balance between marriage and ministry.',
        imageUrl:
            'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=400&h=300&fit=crop',
        memberCount: 89,
        messages: [],
        pinnedMessages: [],
        events: [],
      ),
      WisdomCircleModel(
        id: '3',
        name: 'Motherhood in Christ',
        description:
            'Raising children with biblical wisdom and finding strength in Christian motherhood.',
        imageUrl:
            'https://images.unsplash.com/photo-1476703993599-0035a21b17a9?w=400&h=300&fit=crop',
        memberCount: 156,
        messages: [],
        pinnedMessages: [],
        events: [],
      ),
      WisdomCircleModel(
        id: '4',
        name: 'Healing & Forgiveness',
        description:
            'A safe space for healing from past wounds and learning to forgive.',
        imageUrl:
            'https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=400&h=300&fit=crop',
        memberCount: 203,
        messages: [],
        pinnedMessages: [],
        events: [],
      ),
      WisdomCircleModel(
        id: '5',
        name: 'Mental Health & Faith',
        description:
            'Addressing mental health challenges through faith, prayer, and professional support.',
        imageUrl:
            'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        memberCount: 94,
        messages: [],
        pinnedMessages: [],
        events: [],
      ),
    ];
    notifyListeners();
  }

  Future<void> fetchCircles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _circles = await _wisdomCircleService.getWisdomCircles();
    } catch (e) {
      _error = e.toString();
      _initializeWithMockData();
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
      _joinedCircles.add(circleId);
      final index = _circles.indexWhere((circle) => circle.id == circleId);
      if (index != -1) {
        _circles[index] = _circles[index].copyWith(
          memberCount: _circles[index].memberCount + 1,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
      _joinedCircles.remove(circleId);
      final index = _circles.indexWhere((circle) => circle.id == circleId);
      if (index != -1) {
        _circles[index] = _circles[index].copyWith(
          memberCount: _circles[index].memberCount - 1,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
        _selectedCircle = _selectedCircle!.copyWith(messages: updatedMessages);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleLikeMessage({
    required String circleId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final circle = _selectedCircle;
      if (circle == null || circle.id != circleId) return false;

      final updatedMessages =
          circle.messages.map((message) {
            if (message.id == messageId) {
              final updatedLikes = List<String>.from(message.likes);
              if (updatedLikes.contains(userId)) {
                updatedLikes.remove(userId);
              } else {
                updatedLikes.add(userId);
              }
              return message.copyWith(likes: updatedLikes);
            }
            return message;
          }).toList();

      _selectedCircle = circle.copyWith(messages: updatedMessages);
      notifyListeners();

      await updateMessageLikes(
        circleId: circleId,
        messageId: messageId,
        likes: updatedMessages.firstWhere((m) => m.id == messageId).likes,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateMessageLikes({
    required String circleId,
    required String messageId,
    required List<String> likes,
  }) async {
    try {
      await _wisdomCircleService.updateMessageLikes(
        circleId: circleId,
        messageId: messageId,
        likes: likes,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
