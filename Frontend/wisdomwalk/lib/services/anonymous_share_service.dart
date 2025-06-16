import 'package:wisdomwalk/models/anonymous_share_model.dart';

class AnonymousShareService {
  // Mock data for demonstration
  final List<AnonymousShareModel> _shares = [
    AnonymousShareModel(
      id: '1',
      userId: '1',
      content: 'I\'ve been struggling with forgiveness. Someone hurt me deeply and I know I should forgive, but it\'s so hard. Please pray for my heart to soften.',
      type: AnonymousShareType.confession,
      hearts: ['2', '3'],
      comments: [],
      prayingUsers: ['2'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AnonymousShareModel(
      id: '2',
      userId: '2',
      content: 'God answered my prayers! After months of job searching, I finally got the position I was hoping for. His timing is perfect!',
      type: AnonymousShareType.testimony,
      hearts: ['1', '3', '4'],
      comments: [],
      prayingUsers: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AnonymousShareModel(
      id: '3',
      userId: '3',
      content: 'I\'m going through a really difficult season with my mental health. Some days I can barely get out of bed. I feel so alone.',
      type: AnonymousShareType.struggle,
      hearts: ['1'],
      comments: [],
      prayingUsers: ['1', '2'],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  Future<List<AnonymousShareModel>> getAnonymousShares({AnonymousShareType? type}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (type == null) {
      return _shares;
    }

    return _shares.where((share) => share.type == type).toList();
  }

  Future<AnonymousShareModel> getAnonymousShareDetails(String shareId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final share = _shares.firstWhere(
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
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final share = AnonymousShareModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      type: type,
      hearts: [],
      comments: [],
      prayingUsers: [],
      createdAt: DateTime.now(),
    );

    _shares.insert(0, share);
    return share;
  }

  Future<void> updateHearts({
    required String shareId,
    required List<String> hearts,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _shares.indexWhere((share) => share.id == shareId);
    if (index != -1) {
      _shares[index] = AnonymousShareModel(
        id: _shares[index].id,
        userId: _shares[index].userId,
        content: _shares[index].content,
        type: _shares[index].type,
        hearts: hearts,
        comments: _shares[index].comments,
        prayingUsers: _shares[index].prayingUsers,
        createdAt: _shares[index].createdAt,
      );
    }
  }

  Future<void> updatePrayingUsers({
    required String shareId,
    required List<String> prayingUsers,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _shares.indexWhere((share) => share.id == shareId);
    if (index != -1) {
      _shares[index] = AnonymousShareModel(
        id: _shares[index].id,
        userId: _shares[index].userId,
        content: _shares[index].content,
        type: _shares[index].type,
        hearts: _shares[index].hearts,
        comments: _shares[index].comments,
        prayingUsers: prayingUsers,
        createdAt: _shares[index].createdAt,
      );
    }
  }

  Future<AnonymousShareComment> addComment({
    required String shareId,
    required String userId,
    required String content,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final comment = AnonymousShareComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      createdAt: DateTime.now(),
    );

    final index = _shares.indexWhere((share) => share.id == shareId);
    if (index != -1) {
      final updatedComments = List<AnonymousShareComment>.from(_shares[index].comments)..add(comment);
      _shares[index] = AnonymousShareModel(
        id: _shares[index].id,
        userId: _shares[index].userId,
        content: _shares[index].content,
        type: _shares[index].type,
        hearts: _shares[index].hearts,
        comments: updatedComments,
        prayingUsers: _shares[index].prayingUsers,
        createdAt: _shares[index].createdAt,
      );
    }

    return comment;
  }

  Future<void> sendVirtualHug({
    required String shareId,
    required String userId,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real implementation, this would send a notification
    // to the share author about receiving a virtual hug
    print('Virtual hug sent to share $shareId from user $userId');
  }
}
