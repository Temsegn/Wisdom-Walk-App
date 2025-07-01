import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/services/prayer_service.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();

  List<PrayerModel> _prayers = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all'; // 'all', 'mine', 'friends'

  List<PrayerModel> get prayers => _prayers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  Future<void> fetchPrayers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prayers = await _prayerService.getPrayers(filter: _filter);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _filter = filter;
    fetchPrayers();
  }

  Future<bool> addPrayer({
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
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
      );

      _prayers.insert(0, prayer);
      return true;
    } catch (e) {
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
    try {
      final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
      if (index == -1) return false;

      final prayer = _prayers[index];
      final isPraying = prayer.prayingUsers.contains(userId);

      List<String> updatedPrayingUsers;
      if (isPraying) {
        updatedPrayingUsers = List.from(prayer.prayingUsers)..remove(userId);
      } else {
        updatedPrayingUsers = List.from(prayer.prayingUsers)..add(userId);
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

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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
      if (index == -1) return false;

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

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
