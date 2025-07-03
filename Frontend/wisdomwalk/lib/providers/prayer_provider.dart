import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/services/prayer_service.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService;
  List<PrayerModel> _prayers = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'prayer';
  String _selectedCategory = 'testimony';

  List<PrayerModel> get prayers => _prayers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  PrayerProvider(BuildContext context)
    : _prayerService = PrayerService(
        localStorageService: LocalStorageService(),
      ) {
    print('PrayerProvider: Initializing with filter: $_filter');
    fetchPrayers();
  }

  Future<void> fetchPrayers() async {
    print('PrayerProvider: Fetching prayers with filter: $_filter');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prayers = await _prayerService.getPrayers(filter: _filter);
      print('PrayerProvider: Fetched ${_prayers.length} prayers');
    } catch (e) {
      print('PrayerProvider: Error fetching prayers: $e');
      _error = e.toString();
      _prayers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(String filter) async {
    print('PrayerProvider: Setting filter to $filter');
    _filter = filter;
    await fetchPrayers();
  }

  Future<bool> addPrayer({
    required String userId,
    required String content,
    required bool isAnonymous,
    required String category,
    String? userName,
    String? userAvatar,
    String? title,
  }) async {
    print('PrayerProvider: Adding prayer for user $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prayer = await _prayerService.addPrayer(
        userId: userId,
        content: content,
        isAnonymous: isAnonymous,
        category: category,
        userName: userName,
        userAvatar: userAvatar,
        title: title,
      );
      _prayers.insert(0, prayer);
      print('PrayerProvider: Added prayer ${prayer.id}');
      return true;
    } catch (e) {
      print('PrayerProvider: Error adding prayer: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> togglePraying({
    required String prayerId,
    required String userId,
    String? message,
  }) async {
    print(
      'PrayerProvider: Toggling praying for prayer $prayerId, user $userId',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _prayerService.togglePraying(
        prayerId: prayerId,
        userId: userId,
        message: message,
      );

      if (success) {
        final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
        if (index == -1) {
          print('PrayerProvider: Prayer $prayerId not found');
          return false;
        }

        final prayer = _prayers[index];
        final updatedPrayingUsers =
            prayer.prayingUsers.contains(userId)
                ? prayer.prayingUsers.where((id) => id != userId).toList()
                : [...prayer.prayingUsers, userId];

        _prayers[index] = PrayerModel(
          id: prayer.id,
          userId: prayer.userId,
          userName: prayer.userName,
          userAvatar: prayer.userAvatar,
          content: prayer.content,
          title: prayer.title,
          isAnonymous: prayer.isAnonymous,
          prayingUsers: updatedPrayingUsers,
          virtualHugUsers: prayer.virtualHugUsers,
          likedUsers: prayer.likedUsers,
          reportCount: prayer.reportCount,
          isReported: prayer.isReported,
          comments: prayer.comments,
          createdAt: prayer.createdAt,
        );
        print('PrayerProvider: Updated praying users for prayer $prayerId');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('PrayerProvider: Error toggling praying: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleVirtualHug({
    required String prayerId,
    required String userId,
    String? scripture,
  }) async {
    print(
      'PrayerProvider: Toggling virtual hug for prayer $prayerId, user $userId',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _prayerService.toggleVirtualHug(
        prayerId: prayerId,
        userId: userId,
        scripture: scripture,
      );

      if (success) {
        final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
        if (index == -1) {
          print('PrayerProvider: Prayer $prayerId not found');
          return false;
        }

        final prayer = _prayers[index];
        final updatedVirtualHugUsers =
            prayer.virtualHugUsers.contains(userId)
                ? prayer.virtualHugUsers.where((id) => id != userId).toList()
                : [...prayer.virtualHugUsers, userId];

        _prayers[index] = PrayerModel(
          id: prayer.id,
          userId: prayer.userId,
          userName: prayer.userName,
          userAvatar: prayer.userAvatar,
          content: prayer.content,
          title: prayer.title,
          isAnonymous: prayer.isAnonymous,
          prayingUsers: prayer.prayingUsers,
          virtualHugUsers: updatedVirtualHugUsers,
          likedUsers: prayer.likedUsers,
          reportCount: prayer.reportCount,
          isReported: prayer.isReported,
          comments: prayer.comments,
          createdAt: prayer.createdAt,
        );
        print('PrayerProvider: Updated virtual hug users for prayer $prayerId');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('PrayerProvider: Error toggling virtual hug: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleLike({
    required String prayerId,
    required String userId,
  }) async {
    print('PrayerProvider: Toggling like for prayer $prayerId, user $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _prayerService.toggleLike(
        prayerId: prayerId,
        userId: userId,
      );

      if (success) {
        final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
        if (index == -1) {
          print('PrayerProvider: Prayer $prayerId not found');
          return false;
        }

        final prayer = _prayers[index];
        final updatedLikedUsers =
            prayer.likedUsers.contains(userId)
                ? prayer.likedUsers.where((id) => id != userId).toList()
                : [...prayer.likedUsers, userId];

        _prayers[index] = PrayerModel(
          id: prayer.id,
          userId: prayer.userId,
          userName: prayer.userName,
          userAvatar: prayer.userAvatar,
          content: prayer.content,
          title: prayer.title,
          isAnonymous: prayer.isAnonymous,
          prayingUsers: prayer.prayingUsers,
          virtualHugUsers: prayer.virtualHugUsers,
          likedUsers: updatedLikedUsers,
          reportCount: prayer.reportCount,
          isReported: prayer.isReported,
          comments: prayer.comments,
          createdAt: prayer.createdAt,
        );
        print('PrayerProvider: Updated liked users for prayer $prayerId');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('PrayerProvider: Error toggling like: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reportPost({
    required String prayerId,
    required String userId,
    required String reason,
    String type = 'inappropriate_content',
  }) async {
    print('PrayerProvider: Reporting post $prayerId for user $userId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _prayerService.reportPost(
        prayerId: prayerId,
        userId: userId,
        reason: reason,
        type: type,
      );

      if (success) {
        final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
        if (index == -1) {
          print('PrayerProvider: Prayer $prayerId not found');
          return false;
        }

        final prayer = _prayers[index];
        _prayers[index] = PrayerModel(
          id: prayer.id,
          userId: prayer.userId,
          userName: prayer.userName,
          userAvatar: prayer.userAvatar,
          content: prayer.content,
          title: prayer.title,
          isAnonymous: prayer.isAnonymous,
          prayingUsers: prayer.prayingUsers,
          virtualHugUsers: prayer.virtualHugUsers,
          likedUsers: prayer.likedUsers,
          reportCount: prayer.reportCount + 1,
          isReported: true,
          comments: prayer.comments,
          createdAt: prayer.createdAt,
        );
        print('PrayerProvider: Reported post $prayerId');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('PrayerProvider: Error reporting post: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String prayerId,
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
    print('PrayerProvider: Adding comment to prayer $prayerId');
    try {
      final comment = await _prayerService.addComment(
        prayerId: prayerId,
        userId: userId,
        content: content,
        isAnonymous: isAnonymous,
        userName: userName,
        userAvatar: userAvatar,
      );

      final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
      if (index == -1) {
        print('PrayerProvider: Prayer $prayerId not found');
        return false;
      }

      final prayer = _prayers[index];
      final updatedComments = List<PrayerComment>.from(prayer.comments)
        ..add(comment);

      _prayers[index] = PrayerModel(
        id: prayer.id,
        userId: prayer.userId,
        userName: prayer.userName,
        userAvatar: prayer.userAvatar,
        content: prayer.content,
        title: prayer.title,
        isAnonymous: prayer.isAnonymous,
        prayingUsers: prayer.prayingUsers,
        virtualHugUsers: prayer.virtualHugUsers,
        likedUsers: prayer.likedUsers,
        reportCount: prayer.reportCount,
        isReported: prayer.isReported,
        comments: updatedComments,
        createdAt: prayer.createdAt,
      );
      print('PrayerProvider: Added comment to prayer $prayerId');
      notifyListeners(); // Trigger UI update
      return true;
    } catch (e) {
      print('PrayerProvider: Error adding comment: $e - prayerId: $prayerId');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    print('PrayerProvider: Clearing error');
    _error = null;
    notifyListeners();
  }
}
