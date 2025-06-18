import 'package:wisdomwalk/models/wisdom_circle_model.dart';

class WisdomCircleService {
  static final List<WisdomCircleModel> _mockCircles = [
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

  Future<List<WisdomCircleModel>> getWisdomCircles() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List<WisdomCircleModel>.from(_mockCircles);
  }

  Future<WisdomCircleModel> getWisdomCircleDetails(String circleId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockCircles.firstWhere(
      (circle) => circle.id == circleId,
      orElse: () => throw Exception('Circle not found'),
    );
  }

  Future<void> joinCircle({
    required String circleId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> leaveCircle({
    required String circleId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<WisdomCircleMessage> sendMessage({
    required String circleId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return WisdomCircleMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      createdAt: DateTime.now(),
      likes: [],
    );
  }

  Future<void> updateMessageLikes({
    required String circleId,
    required String messageId,
    required List<String> likes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Simulate API update
  }
}
