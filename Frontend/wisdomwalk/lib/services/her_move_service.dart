import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wisdomwalk/models/location_request_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class HerMoveService {
  static const String _baseUrl =
      'https://wisdom-walk-app.onrender.com/api/movements';
  final LocalStorageService _storageService = LocalStorageService();

  Future<List<LocationRequestModel>> getLocationRequests() async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('getLocationRequests response: $data'); // Debug log
      if (data is List) {
        return data.map((json) => LocationRequestModel.fromJson(json)).toList();
      } else {
        throw Exception('Expected a list in response, got: ${response.body}');
      }
    } else {
      throw Exception('Failed to fetch location requests: ${response.body}');
    }
  }

  Future<LocationRequestModel> getLocationRequestDetails(String moveId) async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/moves/$moveId'), // Use /moves/:moveId
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('getLocationRequestDetails response: $data'); // Debug log
      return LocationRequestModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch request details: ${response.body}');
    }
  }

  Future<List<LocationRequestModel>> searchNearbyHelp({
    required String city,
    required String country,
  }) async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search?city=$city&country=$country'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('searchNearbyHelp response: $data'); // Debug log
      if (data is List) {
        return data.map((json) => LocationRequestModel.fromJson(json)).toList();
      } else {
        throw Exception('Expected a list in response, got: ${response.body}');
      }
    } else {
      throw Exception('Failed to search nearby help: ${response.body}');
    }
  }

  Future<List<LocationRequestModel>> getAllMoves() async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/moves'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('getAllMoves response: $data'); // Debug log
      if (data is List) {
        return data.map((json) => LocationRequestModel.fromJson(json)).toList();
      } else {
        throw Exception('Expected a list in response, got: ${response.body}');
      }
    } else {
      throw Exception('Failed to fetch all moves: ${response.body}');
    }
  }

  Future<LocationRequestModel> addLocationRequest({
    required String userId,
    required String userName,
    String? userAvatar,
    required String city,
    required String country,
    required String description,
    required DateTime moveDate,
    String? fromCity,
    String? fromCountry,
  }) async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'fromLocation':
            fromCity != null && fromCountry != null
                ? {'city': fromCity, 'country': fromCountry}
                : null,
        'toLocation': {'city': city, 'country': country},
        'note': description,
        'movementDate': moveDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      print('addLocationRequest response: $json'); // Debug log
      if (json is Map<String, dynamic>) {
        return LocationRequestModel.fromJson(json);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to add location request: ${response.body}');
    }
  }
}
