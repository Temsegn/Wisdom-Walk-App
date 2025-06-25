import 'package:wisdomwalk/models/prayer_model.dart';

class PrayerService {
  // Mock data for demonstration
  final List<PrayerModel> _prayers = [
    PrayerModel(
      id: '1',
      userId: '1',
      userName: 'Lidaya Mamo',
      userAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
      content:
          'Please pray for my upcoming job interview. I\'m feeling anxious but trusting God\'s plan.',
      isAnonymous: false,
      prayingUsers: ['2', '3'],
      comments: [
        PrayerComment(
          id: '101',
          userId: '2',
          userName: 'Rebecca Smith',
          userAvatar: 'https://randomuser.me/api/portraits/women/67.jpg',
          content: 'Praying for peace and favor! Remember Jeremiah 29:11.',
          isAnonymous: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PrayerModel(
      id: '2',
      userId: '3',
      userName: null,
      userAvatar: null,
      content:
          'My mother is in the hospital. Please pray for her healing and for strength for our family during this difficult time.',
      isAnonymous: true,
      prayingUsers: ['1', '4'],
      comments: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  Future<List<PrayerModel>> getPrayers({String filter = 'all'}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would filter based on the user's ID and friends
    return _prayers;
  }

  Future<PrayerModel> addPrayer({
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final prayer = PrayerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: isAnonymous ? null : userName,
      userAvatar: isAnonymous ? null : userAvatar,
      content: content,
      isAnonymous: isAnonymous,
      prayingUsers: [],
      comments: [],
      createdAt: DateTime.now(),
    );

    _prayers.insert(0, prayer);
    return prayer;
  }

  Future<void> updatePrayingUsers({
    required String prayerId,
    required List<String> prayingUsers,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
    if (index != -1) {
      _prayers[index] = PrayerModel(
        id: _prayers[index].id,
        userId: _prayers[index].userId,
        userName: _prayers[index].userName,
        userAvatar: _prayers[index].userAvatar,
        content: _prayers[index].content,
        isAnonymous: _prayers[index].isAnonymous,
        prayingUsers: prayingUsers,
        comments: _prayers[index].comments,
        createdAt: _prayers[index].createdAt,
      );
    }
  }

  Future<PrayerComment> addComment({
    required String prayerId,
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final comment = PrayerComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: isAnonymous ? null : userName,
      userAvatar: isAnonymous ? null : userAvatar,
      content: content,
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
    );

    final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
    if (index != -1) {
      final updatedComments = List<PrayerComment>.from(_prayers[index].comments)
        ..add(comment);
      _prayers[index] = PrayerModel(
        id: _prayers[index].id,
        userId: _prayers[index].userId,
        userName: _prayers[index].userName,
        userAvatar: _prayers[index].userAvatar,
        content: _prayers[index].content,
        isAnonymous: _prayers[index].isAnonymous,
        prayingUsers: _prayers[index].prayingUsers,
        comments: updatedComments,
        createdAt: _prayers[index].createdAt,
      );
    }

    return comment;
  }
}
