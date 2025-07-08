import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/booking_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class BookingService {
  // Backend API endpoint
  static const String _baseUrl ='https://wisdom-walk-app.onrender.com/api/bookings/book';

  final LocalStorageService _localStorageService = LocalStorageService();

  Future<void> submitBooking(BookingRequest request) async {
    try {
      // Get the authentication token
      final token =
          await _localStorageService
              .getAuthToken(); // Get the authentication token

      // 🔍 Debug print
      print('DEBUG: token = $token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 201) {
        // Success: Booking created
        return;
      } else {
        // Parse error message from backend
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            'Failed to submit booking: ${errorData['message'] ?? response.statusCode}',
          );
        } catch (_) {
          throw Exception(
            'Failed to submit booking: ${response.statusCode} ${response.body}',
          );
        }
      }
    } catch (e) {
      // Rethrow the error for the caller (e.g., BookingForm)
      throw Exception('Error submitting booking: $e');
    }
  }
}
