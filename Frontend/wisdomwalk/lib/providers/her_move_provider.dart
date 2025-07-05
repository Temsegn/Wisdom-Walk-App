import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/location_request_model.dart';
import 'package:wisdomwalk/services/her_move_service.dart';

class HerMoveProvider extends ChangeNotifier {
  final HerMoveService _herMoveService = HerMoveService();

  List<LocationRequestModel> _requests = [];
  LocationRequestModel? _selectedRequest;
  List<LocationRequestModel> _nearbyRequests = [];
  bool _isLoading = false;
  String? _error;

  List<LocationRequestModel> get requests => _requests;
  LocationRequestModel? get selectedRequest => _selectedRequest;
  List<LocationRequestModel> get nearbyRequests => _nearbyRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _herMoveService.getAllMoves();
      if (_requests.isEmpty) {
        _error = 'No travel requests available';
      }
    } catch (e) {
      _error = 'Failed to load requests: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRequestDetails(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRequest = await _herMoveService.getLocationRequestDetails(
        requestId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchNearbyHelp({
    required String city,
    required String country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nearbyRequests = await _herMoveService.searchNearbyHelp(
        city: city,
        country: country,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLocationRequest({
    required String userId,
    required String userName,
    String? userAvatar,
    required String toCity,
    required String toCountry,
    required String description,
    required DateTime moveDate,
    String? fromCity,
    String? fromCountry,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = await _herMoveService.addLocationRequest(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        city: toCity,
        country: toCountry,
        description: description,
        moveDate: moveDate,
        fromCity: fromCity,
        fromCountry: fromCountry,
      );
      _requests.insert(0, request);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelected() {
    _selectedRequest = null;
    notifyListeners();
  }

  void clearNearbyRequests() {
    _nearbyRequests = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
