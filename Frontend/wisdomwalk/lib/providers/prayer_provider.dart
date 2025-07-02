import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/services/prayer_service.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService;
  List<PrayerModel> _prayers = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all'; // Default to 'prayer' for PrayerWallTab

  List<PrayerModel> get prayers => _prayers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  PrayerProvider(BuildContext context)
    : _prayerService = PrayerService(
        localStorageService: LocalStorageService(),
      ) {
    print('PrayerProvider: Initializing with filter: $_filter');
    fetchPrayers(); // Fetch prayers on initialization
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
  }) async {
    print(
      'PrayerProvider: Toggling praying for prayer $prayerId, user $userId',
    );
    try {
      final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
      if (index == -1) {
        print('PrayerProvider: Prayer $prayerId not found');
        return false;
      }

      final prayer = _prayers[index];
      final isPraying = prayer.prayingUsers.contains(userId);
      List<String> updatedPrayingUsers = List.from(prayer.prayingUsers);
      if (isPraying) {
        updatedPrayingUsers.remove(userId);
      } else {
        updatedPrayingUsers.add(userId);
      }

      await _prayerService.updatePrayingUsers(
        prayerId: prayerId,
        prayingUsers: updatedPrayingUsers,
      );

      _prayers[index] = PrayerModel(
        id: prayer.id,
        userId: prayer.userId,
        userName: prayer.userName,
        userAvatar: prayer.userAvatar,
        content: prayer.content,

        isAnonymous: prayer.isAnonymous,
        prayingUsers: updatedPrayingUsers,
        comments: prayer.comments,
        createdAt: prayer.createdAt,
      );
      print('PrayerProvider: Updated praying users for prayer $prayerId');
      notifyListeners();
      return true;
    } catch (e) {
      print('PrayerProvider: Error toggling praying: $e');
      _error = e.toString();
      notifyListeners();
      return false;
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

        isAnonymous: prayer.isAnonymous,
        prayingUsers: prayer.prayingUsers,
        comments: updatedComments,
        createdAt: prayer.createdAt,
      );
      print('PrayerProvider: Added comment to prayer $prayerId');
      notifyListeners();
      return true;
    } catch (e) {
      print('PrayerProvider: Error adding comment: $e');
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
