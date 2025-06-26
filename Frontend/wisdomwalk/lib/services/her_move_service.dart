import 'package:wisdomwalk/models/location_request_model.dart';

class HerMoveService {
  // Mock data for demonstration
  final List<LocationRequestModel> _requests = [
    LocationRequestModel(
      id: '1',
      userId: '1',
      userName: 'Afomiya',
      userAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
      city: 'London',
      country: 'United Kingdom',
      description:
          'Moving to London for work next month. Looking for church recommendations and potential roommates.',
      moveDate: DateTime.now().add(const Duration(days: 30)),
      responses: [
        LocationResponse(
          id: '101',
          userId: '2',
          userName: 'Rebecca Smith',
          userAvatar: 'https://randomuser.me/api/portraits/women/67.jpg',
          content:
              'Welcome to London! I attend Grace Community Church and love it. Happy to show you around when you arrive.',
          isChurch: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        LocationResponse(
          id: '102',
          userId: '3',
          userName: 'Admin',
          userAvatar: null,
          content: 'Here\'s a church you might like to visit.',
          isChurch: true,
          churchName: 'London Community Church',
          churchAddress: '123 Faith Street, London',
          churchWebsite: 'www.lcc.org',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    LocationRequestModel(
      id: '2',
      userId: '3',
      userName: 'Emily Davis',
      userAvatar: 'https://randomuser.me/api/portraits/women/33.jpg',
      city: 'Addis Ababa',
      country: 'Ethiopia',
      description:
          'I\'m relocating to Addis Ababa for missionary work. Looking for housing advice and local connections.',
      moveDate: DateTime.now().add(const Duration(days: 45)),
      responses: [],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Mock nearby responses
  final List<LocationResponse> _nearbyResponses = [
    LocationResponse(
      id: '201',
      userId: '4',
      userName: 'Local Sister',
      userAvatar: 'https://randomuser.me/api/portraits/women/22.jpg',
      content:
          'I\'ve lived in this area for 5 years and would be happy to help you get settled.',
      isChurch: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LocationResponse(
      id: '202',
      userId: '5',
      userName: 'Admin',
      userAvatar: null,
      content: 'This church is near your destination.',
      isChurch: true,
      churchName: 'Faith Community Church',
      churchAddress: '456 Hope Avenue',
      churchWebsite: 'www.faithcommunity.org',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<LocationRequestModel>> getLocationRequests() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    return _requests;
  }

  Future<LocationRequestModel> getLocationRequestDetails(
    String requestId,
  ) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final request = _requests.firstWhere(
      (request) => request.id == requestId,
      orElse: () => throw Exception('Request not found'),
    );

    return request;
  }

  Future<List<LocationResponse>> searchNearbyHelp({
    required String city,
    required String country,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would filter based on location
    return _nearbyResponses;
  }

  Future<LocationRequestModel> addLocationRequest({
    required String userId,
    required String userName,
    String? userAvatar,
    required String city,
    required String country,
    required String description,
    required DateTime moveDate,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final request = LocationRequestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      city: city,
      country: country,
      description: description,
      moveDate: moveDate,
      responses: [],
      createdAt: DateTime.now(),
    );

    _requests.insert(0, request);
    return request;
  }

  Future<LocationResponse> addLocationResponse({
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
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final response = LocationResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      isChurch: isChurch,
      churchName: churchName,
      churchAddress: churchAddress,
      churchWebsite: churchWebsite,
      createdAt: DateTime.now(),
    );

    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index != -1) {
      final updatedResponses = List<LocationResponse>.from(
        _requests[index].responses,
      )..add(response);
      _requests[index] = LocationRequestModel(
        id: _requests[index].id,
        userId: _requests[index].userId,
        userName: _requests[index].userName,
        userAvatar: _requests[index].userAvatar,
        city: _requests[index].city,
        country: _requests[index].country,
        description: _requests[index].description,
        moveDate: _requests[index].moveDate,
        responses: updatedResponses,
        createdAt: _requests[index].createdAt,
      );
    }

    return response;
  }
}
