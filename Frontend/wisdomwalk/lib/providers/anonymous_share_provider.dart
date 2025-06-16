import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/services/anonymous_share_service.dart';

class AnonymousShareProvider extends ChangeNotifier {
  final AnonymousShareService _anonymousShareService = AnonymousShareService();

  List<AnonymousShareModel> _shares = [];
  AnonymousShareModel? _selectedShare;
  bool _isLoading = false;
  String? _error;
  AnonymousShareType _filter = AnonymousShareType.confession;

  List<AnonymousShareModel> get shares => _shares;
  AnonymousShareModel? get selectedShare => _selectedShare;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnonymousShareType get filter => _filter;

  Future<void> fetchShares({AnonymousShareType? type}) async {
    _isLoading = true;
    _error = null;
    if (type != null) {
      _filter = type;
    }
    notifyListeners();

    try {
      _shares = await _anonymousShareService.getAnonymousShares(type: _filter);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShareDetails(String shareId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedShare = await _anonymousShareService.getAnonymousShareDetails(
        shareId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addShare({
    required String userId,
    required String content,
    required AnonymousShareType type,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final share = await _anonymousShareService.addAnonymousShare(
        userId: userId,
        content: content,
        type: type,
      );

      if (type == _filter) {
        _shares.insert(0, share);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleHeart({
    required String shareId,
    required String userId,
  }) async {
    try {
      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index == -1) return false;

      final share = _shares[index];
      final hasHeart = share.hearts.contains(userId);

      List<String> updatedHearts;
      if (hasHeart) {
        updatedHearts = List.from(share.hearts)..remove(userId);
      } else {
        updatedHearts = List.from(share.hearts)..add(userId);
      }

      await _anonymousShareService.updateHearts(
        shareId: shareId,
        hearts: updatedHearts,
      );

      _shares[index] = AnonymousShareModel(
        id: share.id,
        userId: share.userId,
        content: share.content,
        type: share.type,
        hearts: updatedHearts,
        comments: share.comments,
        prayingUsers: share.prayingUsers,
        createdAt: share.createdAt,
      );

      if (_selectedShare?.id == shareId) {
        _selectedShare = AnonymousShareModel(
          id: _selectedShare!.id,
          userId: _selectedShare!.userId,
          content: _selectedShare!.content,
          type: _selectedShare!.type,
          hearts: updatedHearts,
          comments: _selectedShare!.comments,
          prayingUsers: _selectedShare!.prayingUsers,
          createdAt: _selectedShare!.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> togglePraying({
    required String shareId,
    required String userId,
  }) async {
    try {
      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index == -1) return false;

      final share = _shares[index];
      final isPraying = share.prayingUsers.contains(userId);

      List<String> updatedPrayingUsers;
      if (isPraying) {
        updatedPrayingUsers = List.from(share.prayingUsers)..remove(userId);
      } else {
        updatedPrayingUsers = List.from(share.prayingUsers)..add(userId);
      }

      await _anonymousShareService.updatePrayingUsers(
        shareId: shareId,
        prayingUsers: updatedPrayingUsers,
      );

      _shares[index] = AnonymousShareModel(
        id: share.id,
        userId: share.userId,
        content: share.content,
        type: share.type,
        hearts: share.hearts,
        comments: share.comments,
        prayingUsers: updatedPrayingUsers,
        createdAt: share.createdAt,
      );

      if (_selectedShare?.id == shareId) {
        _selectedShare = AnonymousShareModel(
          id: _selectedShare!.id,
          userId: _selectedShare!.userId,
          content: _selectedShare!.content,
          type: _selectedShare!.type,
          hearts: _selectedShare!.hearts,
          comments: _selectedShare!.comments,
          prayingUsers: updatedPrayingUsers,
          createdAt: _selectedShare!.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> addComment({
    required String shareId,
    required String userId,
    required String content,
  }) async {
    try {
      final comment = await _anonymousShareService.addComment(
        shareId: shareId,
        userId: userId,
        content: content,
      );

      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index != -1) {
        final share = _shares[index];
        final updatedComments = List<AnonymousShareComment>.from(share.comments)
          ..add(comment);

        _shares[index] = AnonymousShareModel(
          id: share.id,
          userId: share.userId,
          content: share.content,
          type: share.type,
          hearts: share.hearts,
          comments: updatedComments,
          prayingUsers: share.prayingUsers,
          createdAt: share.createdAt,
        );
      }

      if (_selectedShare?.id == shareId) {
        final updatedComments = List<AnonymousShareComment>.from(
          _selectedShare!.comments,
        )..add(comment);

        _selectedShare = AnonymousShareModel(
          id: _selectedShare!.id,
          userId: _selectedShare!.userId,
          content: _selectedShare!.content,
          type: _selectedShare!.type,
          hearts: _selectedShare!.hearts,
          comments: updatedComments,
          prayingUsers: _selectedShare!.prayingUsers,
          createdAt: _selectedShare!.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> sendVirtualHug({
    required String shareId,
    required String userId,
  }) async {
    try {
      await _anonymousShareService.sendVirtualHug(
        shareId: shareId,
        userId: userId,
      );

      // You could also update local state here if needed
      // For example, add to a virtualHugs list in the model

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilter(AnonymousShareType type) {
    _filter = type;
    fetchShares();
  }

  void clearSelectedShare() {
    _selectedShare = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
