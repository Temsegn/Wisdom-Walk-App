import 'package:wisdomwalk/models/anonymous_share_model.dart';

class AnonymousShareService {
  static final List<AnonymousShareModel> _mockShares = [
    AnonymousShareModel(
      id: '1',
      userId: 'user1',
      content:
          'I\'ve been struggling with forgiveness. Someone hurt me deeply and I know God calls us to forgive, but my heart feels so heavy. Please pray for me to find peace.',
      type: AnonymousShareType.confession,
      hearts: ['user2', 'user3'],
      comments: [
        AnonymousShareComment(
          id: 'c1',
          userId: 'user2',
          userName: 'Sister Grace',
          content:
              'Praying for your heart to heal. Forgiveness is a process, not a moment. Be patient with yourself. 💕',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      prayingUsers: ['user2', 'user3', 'user4'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    // Add other mock shares as in your original code...
    // (Keeping it concise here; include all from your original file)
    AnonymousShareModel(
      id: '2',
      userId: 'user2',
      content:
          'I feel like I\'m not good enough for God\'s love. My past mistakes keep haunting me and I struggle to believe I\'m truly forgiven.',
      type: AnonymousShareType.confession,
      hearts: ['user1', 'user4'],
      comments: [],
      prayingUsers: ['user1', 'user3'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AnonymousShareModel(
      id: '3',
      userId: 'user3',
      content:
          'God answered my prayers! I was unemployed for 6 months and felt hopeless. Today I got a job offer that\'s even better than what I was praying for. His timing is perfect! 🙌',
      type: AnonymousShareType.testimony,
      hearts: ['user1', 'user2', 'user4', 'user5'],
      comments: [
        AnonymousShareComment(
          id: 'c2',
          userId: 'user1',
          userName: 'Faithful Sister',
          content:
              'Praise God! This gives me hope for my own situation. Thank you for sharing! 🙏',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
      prayingUsers: ['user1', 'user2'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AnonymousShareModel(
      id: '4',
      userId: 'user4',
      content:
          'My marriage was on the brink of divorce. We started praying together daily and attending counseling. Today marks 6 months of healing and our relationship is stronger than ever. Prayer works!',
      type: AnonymousShareType.testimony,
      hearts: ['user1', 'user2', 'user3'],
      comments: [],
      prayingUsers: ['user5'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AnonymousShareModel(
      id: '5',
      userId: 'user5',
      content:
          'I\'ve been battling anxiety and depression. Some days I can barely get out of bed. I know God is with me but I feel so alone. How do you find strength when everything feels overwhelming?',
      type: AnonymousShareType.struggle,
      hearts: ['user1', 'user3'],
      comments: [
        AnonymousShareComment(
          id: 'c3',
          userId: 'user3',
          userName: 'Hope Bearer',
          content:
              'I understand this struggle deeply. You\'re not alone. Have you considered Christian counseling? It helped me tremendously. Praying for you. 💙',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        AnonymousShareComment(
          id: 'c4',
          userId: 'user2',
          userName: 'Warrior Sister',
          content:
              'Psalm 34:18 - The Lord is close to the brokenhearted. You are seen and loved. Take it one day at a time. 🤗',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ],
      prayingUsers: ['user1', 'user2', 'user3', 'user4'],
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    // Add remaining mock shares as needed...
  ];

  List<AnonymousShareModel> getMockShares() {
    print(
      'AnonymousShareService: getMockShares called - returning ${_mockShares.length} shares',
    );
    return List.from(_mockShares);
  }

  Future<List<AnonymousShareModel>> getAllAnonymousShares() async {
    print('AnonymousShareService: getAllAnonymousShares called');
    await Future.delayed(const Duration(milliseconds: 500));
    print(
      'AnonymousShareService: Returning ${_mockShares.length} total shares',
    );
    return List.from(_mockShares);
  }

  Future<List<AnonymousShareModel>> getAnonymousShares({
    AnonymousShareType? type,
  }) async {
    print('AnonymousShareService: getAnonymousShares called with type: $type');
    await Future.delayed(const Duration(milliseconds: 500));

    if (type == null) {
      print(
        'AnonymousShareService: Returning all ${_mockShares.length} shares',
      );
      return List.from(_mockShares);
    }

    final filteredShares =
        _mockShares.where((share) => share.type == type).toList();
    print(
      'AnonymousShareService: Returning ${filteredShares.length} shares for type: $type',
    );
    return filteredShares;
  }

  Future<AnonymousShareModel> getAnonymousShareDetails(String shareId) async {
    print(
      'AnonymousShareService: getAnonymousShareDetails called for ID: $shareId',
    );
    await Future.delayed(const Duration(milliseconds: 300));

    final share = _mockShares.firstWhere(
      (share) => share.id == shareId,
      orElse: () => throw Exception('Share not found'),
    );

    return share;
  }

  Future<AnonymousShareModel> addAnonymousShare({
    required String userId,
    required String content,
    required AnonymousShareType type,
  }) async {
    print('AnonymousShareService: addAnonymousShare called');
    await Future.delayed(const Duration(milliseconds: 300));

    final newShare = AnonymousShareModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      type: type,
      hearts: [],
      comments: [],
      prayingUsers: [],
      createdAt: DateTime.now(),
    );

    _mockShares.insert(0, newShare);
    return newShare;
  }

  Future<void> updateHearts({
    required String shareId,
    required List<String> hearts,
  }) async {
    print('AnonymousShareService: updateHearts called');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> updatePrayingUsers({
    required String shareId,
    required List<String> prayingUsers,
  }) async {
    print('AnonymousShareService: updatePrayingUsers called');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<AnonymousShareComment> addComment({
    required String shareId,
    required String userId,
    required String content,
  }) async {
    print('AnonymousShareService: addComment called');
    await Future.delayed(const Duration(milliseconds: 300));

    return AnonymousShareComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: 'Anonymous Sister',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  Future<void> sendVirtualHug({
    required String shareId,
    required String userId,
  }) async {
    print('AnonymousShareService: sendVirtualHug called');
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
