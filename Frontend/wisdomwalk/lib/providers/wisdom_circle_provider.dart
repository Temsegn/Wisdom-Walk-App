import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/services/wisdom_circle_service.dart';

class WisdomCircleProvider extends ChangeNotifier {
  final WisdomCircleService _wisdomCircleService = WisdomCircleService();

  List<WisdomCircleModel> _circles = [];
  WisdomCircleModel? _selectedCircle;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WisdomCircleModel> get circles => _circles;
  WisdomCircleModel? get selectedCircle => _selectedCircle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor - Initialize with mock data immediately
  WisdomCircleProvider() {
    print('WisdomCircleProvider: Constructor called');
    _initializeWithMockData();
  }

  // Initialize with mock data immediately (no async needed)
  void _initializeWithMockData() {
    print('WisdomCircleProvider: Initializing with mock data');
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
    print(
      'WisdomCircleProvider: Mock data initialized with ${_circles.length} circles',
    );
    notifyListeners();
  }

  Future<void> fetchCircles() async {
    print('WisdomCircleProvider: fetchCircles() called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('WisdomCircleProvider: About to call service.getWisdomCircles()');
      final fetchedCircles = await _wisdomCircleService.getWisdomCircles();
      print(
        'WisdomCircleProvider: Service returned ${fetchedCircles.length} circles',
      );

      _circles = fetchedCircles;
      print(
        'WisdomCircleProvider: Successfully set ${_circles.length} circles',
      );
    } catch (e) {
      print('WisdomCircleProvider: Error in fetchCircles: $e');
      _error = e.toString();

      // Fallback to mock data if service fails
      print('WisdomCircleProvider: Using fallback mock data');
      _initializeWithMockData();
    } finally {
      _isLoading = false;
      print(
        'WisdomCircleProvider: fetchCircles completed, notifying listeners',
      );
      notifyListeners();
    }
  }

  // Force refresh method for debugging
  void forceRefresh() {
    print('WisdomCircleProvider: forceRefresh() called');
    _initializeWithMockData();
  }

  Future<void> fetchCircleDetails(String circleId) async {
    print('WisdomCircleProvider: fetchCircleDetails($circleId) called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCircle = await _wisdomCircleService.getWisdomCircleDetails(
        circleId,
      );
      print(
        'WisdomCircleProvider: Circle details fetched for ${_selectedCircle?.name}',
      );
    } catch (e) {
      print('WisdomCircleProvider: Error fetching circle details: $e');
      _error = e.toString();
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

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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

  void toggleLikeMessage({
    required String circleId,
    required String messageId,
    required String userId,
  }) {}
}
