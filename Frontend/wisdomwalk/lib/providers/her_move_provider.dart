import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/location_request_model.dart';
import 'package:wisdomwalk/services/her_move_service.dart';

class HerMoveProvider extends ChangeNotifier {
  final HerMoveService _herMoveService = HerMoveService();

  List<LocationRequestModel> _requests = [];
  LocationRequestModel? _selectedRequest;
  List<LocationResponse> _nearbyResponses = [];
  bool _isLoading = false;
  String? _error;

  List<LocationRequestModel> get requests => _requests;
  LocationRequestModel? get selectedRequest => _selectedRequest;
  List<LocationResponse> get nearbyResponses => _nearbyResponses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _herMoveService.getLocationRequests();
    } catch (e) {
      _error = e.toString();
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
      _nearbyResponses = await _herMoveService.searchNearbyHelp(
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
    required String city,
    required String country,
    required String description,
    required DateTime moveDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = await _herMoveService.addLocationRequest(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        city: city,
        country: country,
        description: description,
        moveDate: moveDate,
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

  Future<bool> addLocationResponse({
    required String requestId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
    bool isChurch = false,
    String? churchName,
    String? churchAddress,
    String? churchWebsite,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _herMoveService.addLocationResponse(
        requestId: requestId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        content: content,
        isChurch: isChurch,
        churchName: churchName,
        churchAddress: churchAddress,
        churchWebsite: churchWebsite,
      );

      // Update the request in the list
      final index = _requests.indexWhere((request) => request.id == requestId);
      if (index != -1) {
        final request = _requests[index];
        final updatedResponses = List<LocationResponse>.from(request.responses)
          ..add(response);
        _requests[index] = LocationRequestModel(
          id: request.id,
          userId: request.userId,
          userName: request.userName,
          userAvatar: request.userAvatar,
          city: request.city,
          country: request.country,
          description: request.description,
          moveDate: request.moveDate,
          responses: updatedResponses,
          createdAt: request.createdAt,
        );
      }

      // Update the selected request if it's the same
      if (_selectedRequest?.id == requestId) {
        final updatedResponses = List<LocationResponse>.from(
          _selectedRequest!.responses,
        )..add(response);
        _selectedRequest = LocationRequestModel(
          id: _selectedRequest!.id,
          userId: _selectedRequest!.userId,
          userName: _selectedRequest!.userName,
          userAvatar: _selectedRequest!.userAvatar,
          city: _selectedRequest!.city,
          country: _selectedRequest!.country,
          description: _selectedRequest!.description,
          moveDate: _selectedRequest!.moveDate,
          responses: updatedResponses,
          createdAt: _selectedRequest!.createdAt,
        );
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

  void clearSelected() {
    _selectedRequest = null;
    notifyListeners();
  }

  void clearNearbyResponses() {
    _nearbyResponses = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
