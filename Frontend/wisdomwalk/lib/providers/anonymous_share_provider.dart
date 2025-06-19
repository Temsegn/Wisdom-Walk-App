import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/services/anonymous_share_service.dart';

class AnonymousShareProvider extends ChangeNotifier {
  final AnonymousShareService _anonymousShareService = AnonymousShareService();

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
    _initializeWithMockData();
  }

  void _initializeWithMockData() {
    print('AnonymousShareProvider: Initializing with mock data');
    try {
      _allShares = _anonymousShareService.getMockShares();
      _shares = List.from(_allShares);
      _showingAll = true;
      print(
        'AnonymousShareProvider: Initialized with ${_shares.length} shares',
      );
      notifyListeners();
    } catch (e) {
      print('AnonymousShareProvider: Error initializing mock data: $e');
    }
  }

  Future<void> fetchAllShares() async {
    print('AnonymousShareProvider: fetchAllShares called');
    _isLoading = true;
    _error = null;
    _showingAll = true;
    notifyListeners();

    try {
      final fetchedShares =
          await _anonymousShareService.getAllAnonymousShares();
      _allShares = fetchedShares;
      _shares = List.from(_allShares);
      print(
        'AnonymousShareProvider: Successfully fetched ${_shares.length} total shares',
      );
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error fetching all shares: $e');
      _allShares = _anonymousShareService.getMockShares();
      _shares = List.from(_allShares);
      print(
        'AnonymousShareProvider: Using fallback mock data with ${_shares.length} shares',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShares({AnonymousShareType? type}) async {
    print('AnonymousShareProvider: fetchShares called with type: $type');
    _isLoading = true;
    _error = null;
    _showingAll = false;
    if (type != null) {
      _filter = type;
    }
    notifyListeners();

    try {
      final fetchedShares = await _anonymousShareService.getAnonymousShares(
        type: _filter,
      );
      _shares = fetchedShares;
      print(
        'AnonymousShareProvider: Successfully fetched ${_shares.length} shares for type: $_filter',
      );
    } catch (e) {
      _error = e.toString();
      print('AnonymousShareProvider: Error fetching shares: $e');
      final mockShares = _anonymousShareService.getMockShares();
      _shares = mockShares.where((share) => share.type == _filter).toList();
      print(
        'AnonymousShareProvider: Using fallback filtered mock data with ${_shares.length} shares',
      );
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
    print('AnonymousShareProvider: addShare called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final share = await _anonymousShareService.addAnonymousShare(
        userId: userId,
        content: content,
        type: type,
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

        final allIndex = _allShares.indexWhere((share) => share.id == shareId);
        if (allIndex != -1) {
          _allShares[allIndex] = _shares[index];
        }
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
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilter(AnonymousShareType type) {
    print('AnonymousShareProvider: setFilter called with type: $type');
    _filter = type;
    _showingAll = false;
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