import 'dart:convert';
import '../Helper/http_client.dart';
import '../Resources/API.dart';
import '../Models/booking.dart';
import '../Services/auth_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final AuthService _authService = AuthService();

  /// Update booking with full booking object (description + all other fields)
  Future<bool> updateBooking({
    required Booking booking,
    required String newDescription,
  }) async {
    final uri = Uri.parse('${API.base_url}/bookings/${booking.id}');

    print('🔍 Attempting to update booking:');
    print('   URL: $uri');
    print('   Booking ID: ${booking.id}');
    print('   New Description: $newDescription');

    try {

      final body = jsonEncode({
        'start': booking.startTime.toUtc().toIso8601String(),
        'end': booking.endTime.toUtc().toIso8601String(),
        'description': newDescription,
      });

      print('   Request Body: $body');

      final response = await HttpClient.put(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('✅ Response Status: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error: $e');
      print('❌ Stack: ${StackTrace.current}');
      rethrow;
    }
  }


  /// Cancel / delete booking
  Future<bool> cancelBooking(String bookingId) async {
    final uri = Uri.parse('${API.base_url}/bookings/$bookingId');

    print('🗑️ Attempting to cancel booking:');
    print('   URL: $uri');
    print('   Booking ID: $bookingId');
    print('   Token: ${_authService.token?.substring(0, 20)}...');

    try {
      final response = await HttpClient.delete(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
      );

      print('✅ Response Status: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error: $e');
      print('❌ Stack: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Check in to a booking with code
  Future<bool> checkInBooking({
    required int bookingId,
    required String code,
  }) async {
    final uri = Uri.parse('${API.base_url}${API.checkInBooking}');

    print('✅ Attempting to check in:');
    print('   URL: $uri');
    print('   Booking ID: $bookingId');
    print('   Code: $code');

    try {
      final body = jsonEncode({
        'bookingId': bookingId,
        'code': code,
      });

      print('   Request Body: $body');

      final response = await HttpClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('✅ Response Status: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error: $e');
      print('❌ Stack: ${StackTrace.current}');
      rethrow;
    }
  }
}
