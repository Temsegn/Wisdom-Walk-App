import 'package:wisdomwalk/models/wisdom_circle_model.dart';

class WisdomCircleService {
  // Mock data for wisdom circles
  static final List<WisdomCircleModel> _mockCircles = [
    WisdomCircleModel(
      id: '1',
      name: 'Single & Purposeful',
      description:
          'A supportive community for single women walking in their God-given purpose and embracing their season of singleness.',
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
          'Navigating the beautiful balance between marriage and ministry, supporting wives in their calling.',
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
          'A safe space for healing from past wounds and learning to forgive as Christ forgave us.',
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
    print('WisdomCircleService: getWisdomCircles called');
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    print('WisdomCircleService: Returning ${_mockCircles.length} circles');
    return List.from(_mockCircles);
  }

  Future<WisdomCircleModel> getWisdomCircleDetails(String circleId) async {
    print(
      'WisdomCircleService: getWisdomCircleDetails called for ID: $circleId',
    );
    await Future.delayed(const Duration(milliseconds: 300));

    final circle = _mockCircles.firstWhere(
      (circle) => circle.id == circleId,
      orElse: () => throw Exception('Circle not found'),
    );

    return circle;
  }

  Future<void> joinCircle({
    required String circleId,
    required String userId,
  }) async {
    print(
      'WisdomCircleService: joinCircle called - Circle: $circleId, User: $userId',
    );
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would make an API call
  }

  Future<void> leaveCircle({
    required String circleId,
    required String userId,
  }) async {
    print(
      'WisdomCircleService: leaveCircle called - Circle: $circleId, User: $userId',
    );
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would make an API call
  }

  Future<WisdomCircleMessage> sendMessage({
    required String circleId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
  }) async {
    print('WisdomCircleService: sendMessage called');
    await Future.delayed(const Duration(milliseconds: 300));

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
    print('WisdomCircleService: updateMessageLikes called');
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real app, this would update the message likes
  }
}
