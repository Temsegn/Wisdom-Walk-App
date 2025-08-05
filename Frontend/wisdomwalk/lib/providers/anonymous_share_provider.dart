import 'package:flutter/material.dart';
import '../models/anonymous_share_model.dart';
import '../services/anonymous_share_service.dart';
import '../services/local_storage_service.dart';

class AnonymousShareProvider extends ChangeNotifier {
  final AnonymousShareService _anonymousShareService = AnonymousShareService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<AnonymousShareModel> _shares = [];
  List<AnonymousShareModel> _allShares = [];
  AnonymousShareModel? _selectedShare;
  bool _isLoading = false;
  String? _error;
  AnonymousShareType _filter = AnonymousShareType.confession;
  bool _showingAll = false;

  List<AnonymousShareModel> get shares => _shares;
  AnonymousShareModel? get selectedShare => _selectedShare;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnonymousShareType get filter => _filter;
  bool get showingAll => _showingAll;

  AnonymousShareProvider() {
    print('AnonymousShareProvider: Constructor called');
    fetchAllShares();
  }

  Future<void> fetchAllShares() async {
    print('AnonymousShareProvider: fetchAllShares called');
    _isLoading = true;
    _error = null;
    _showingAll = true;
    notifyListeners();

    try {
      _allShares = await _anonymousShareService.getAllAnonymousShares();
      _shares = List.from(_allShares);
      print(
        'AnonymousShareProvider: Successfully fetched ${_shares.length} total shares',
      );
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error fetching all shares: $e');
      _shares = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShares({required AnonymousShareType type}) async {
    print('AnonymousShareProvider: fetchShares called with type: $type');
    _isLoading = true;
    _error = null;
    _showingAll = false;
    _filter = type;
    notifyListeners();

    try {
      _shares = await _anonymousShareService.getAnonymousShares(type: type);
      print(
        'AnonymousShareProvider: Successfully fetched ${_shares.length} shares for type: $type',
      );
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error fetching shares: $e');
      _shares = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forceRefreshAll() async {
    print('AnonymousShareProvider: forceRefreshAll called');
    _shares.clear();
    _allShares.clear();
    notifyListeners();
    await fetchAllShares();
  }

  Future<void> forceRefresh(AnonymousShareType type) async {
    print('AnonymousShareProvider: forceRefresh called for type: $type');
    _shares.clear();
    notifyListeners();
    await fetchShares(type: type);
  }

  Future<void> fetchShareDetails(String shareId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedShare = await _anonymousShareService.getAnonymousShareDetails(
        shareId,
      );
      _selectedShare = _selectedShare!.copyWith(
        comments: await _anonymousShareService.getPostComments(shareId),
      );
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error fetching share details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addShare({
    required String userId,
    required String content,
    required AnonymousShareType type,
    String? title,
    List<Map<String, String>> images = const [],
  }) async {
    print('AnonymousShareProvider: addShare called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final share = await _anonymousShareService.addAnonymousShare(
        userId: userId,
        content: content,
        type: type,
        title: title,
        images: images,
        token: token,
      );

      _allShares.insert(0, share);
      if (_showingAll || type == _filter) {
        _shares.insert(0, share);
      }

      print('AnonymousShareProvider: Successfully added share');
      return true;
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error adding share: $e');
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
    print('AnonymousShareProvider: toggleHeart called');
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index == -1) return false;

      final share = _shares[index];
      final hasHeart = share.likes.contains(userId);

      await _anonymousShareService.updateHearts(
        shareId: shareId,
        userId: userId,
        token: token,
      );

      List<String> updatedLikes;
      if (hasHeart) {
        updatedLikes = List<String>.from(share.likes)..remove(userId);
      } else {
        updatedLikes = List<String>.from(share.likes)..add(userId);
      }

      _shares[index] = share.copyWith(likes: updatedLikes);

      final allIndex = _allShares.indexWhere((share) => share.id == shareId);
      if (allIndex != -1) {
        _allShares[allIndex] = _shares[index];
      }

      if (_selectedShare?.id == shareId) {
        _selectedShare = _shares[index];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error toggling heart: $e');
      return false;
    }
  }

  Future<bool> togglePraying({
    required String shareId,
    required String userId,
    String? message,
  }) async {
    print('AnonymousShareProvider: togglePraying called');
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index == -1) return false;

      final share = _shares[index];
      final isPraying = share.prayers.any((prayer) => prayer['user'] == userId);

      await _anonymousShareService.updatePrayingUsers(
        shareId: shareId,
        userId: userId,
        message: message,
        token: token,
      );

      final updatedPrayers =
          isPraying
              ? (() {
                final list = List<Map<String, dynamic>>.from(share.prayers);
                list.removeWhere((prayer) => prayer['user'] == userId);
                return list;
              })()
              : (() {
                final list = List<Map<String, dynamic>>.from(share.prayers);
                list.add({
                  'user': userId,
                  'message': message ?? 'Praying for you ❤️',
                  'createdAt': DateTime.now(),
                });
                return list;
              })();

      _shares[index] = share.copyWith(prayers: updatedPrayers);

      final allIndex = _allShares.indexWhere((share) => share.id == shareId);
      if (allIndex != -1) {
        _allShares[allIndex] = _shares[index];
      }

      if (_selectedShare?.id == shareId) {
        _selectedShare = _shares[index];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error toggling prayer: $e');
      return false;
    }
  }

  Future<bool> sendVirtualHug({
    required String shareId,
    required String userId,
    String? scripture,
  }) async {
    print('AnonymousShareProvider: sendVirtualHug called');
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index == -1) return false;

      final share = _shares[index];
      final hasHugged = share.virtualHugs.any((hug) => hug['user'] == userId);

      if (!hasHugged) {
        await _anonymousShareService.sendVirtualHug(
          shareId: shareId,
          userId: userId,
          scripture: scripture,
          token: token,
        );

        final updatedHugs = List<Map<String, dynamic>>.from(share.virtualHugs)
          ..add({
            'user': userId,
            'scripture': scripture ?? '',
            'createdAt': DateTime.now(),
          });

        _shares[index] = share.copyWith(virtualHugs: updatedHugs);

        final allIndex = _allShares.indexWhere((share) => share.id == shareId);
        if (allIndex != -1) {
          _allShares[allIndex] = _shares[index];
        }

        if (_selectedShare?.id == shareId) {
          _selectedShare = _shares[index];
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to send virtual hug: $e';
      print('AnonymousShareProvider: Error sending virtual hug: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment({
    required String shareId,
    required String userId,
    required String content,
  }) async {
    print('AnonymousShareProvider: addComment called');
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final comment = await _anonymousShareService.addComment(
        shareId: shareId,
        userId: userId,
        content: content,
        token: token,
      );

      final index = _shares.indexWhere((share) => share.id == shareId);
      if (index != -1) {
        final share = _shares[index];
        final updatedComments = List<AnonymousShareComment>.from(share.comments)
          ..add(comment);

        _shares[index] = share.copyWith(
          comments: updatedComments,
          commentsCount: share.commentsCount + 1,
        );

        final allIndex = _allShares.indexWhere((share) => share.id == shareId);
        if (allIndex != -1) {
          _allShares[allIndex] = _shares[index];
        }
      }

      if (_selectedShare?.id == shareId) {
        final updatedComments = List<AnonymousShareComment>.from(
          _selectedShare!.comments,
        )..add(comment);
        _selectedShare = _selectedShare!.copyWith(
          comments: updatedComments,
          commentsCount: _selectedShare!.commentsCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error adding comment: $e');
      return false;
    }
  }

  Future<bool> reportShare({
    required String shareId,
    required String userId,
    required String reason,
  }) async {
    print('AnonymousShareProvider: reportShare called');
    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      await _anonymousShareService.reportShare(
        shareId: shareId,
        userId: userId,
        reason: reason,
        token: token,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error reporting share: $e');
      notifyListeners();
      return false;
    }
  }

  void setFilter(AnonymousShareType type) {
    print('AnonymousShareProvider: setFilter called with type: $type');
    _filter = type;
    _showingAll = false;
    fetchShares(type: type);
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

extension AnonymousShareModelExtension on AnonymousShareModel {
  AnonymousShareModel copyWith({
    String? id,
    String? userId,
    String? content,
    AnonymousShareType? category,
    String? title,
    List<Map<String, String>>? images,
    bool? isAnonymous,
    List<String>? likes,
    List<Map<String, dynamic>>? prayers,
    List<Map<String, dynamic>>? virtualHugs,
    int? commentsCount,
    List<AnonymousShareComment>? comments,
    bool? isReported,
    int? reportCount,
    bool? isHidden,
    List<String>? tags,
    DateTime? scheduledFor,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return AnonymousShareModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      category: category ?? this.category,
      title: title ?? this.title,
      images: images ?? this.images,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likes: likes ?? this.likes,
      prayers: prayers ?? this.prayers,
      virtualHugs: virtualHugs ?? this.virtualHugs,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
      isReported: isReported ?? this.isReported,
      reportCount: reportCount ?? this.reportCount,
      isHidden: isHidden ?? this.isHidden,
      tags: tags ?? this.tags,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
