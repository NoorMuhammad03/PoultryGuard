import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/flock.dart';

class FlockService {
  FlockService._();

  static Future<List<Flock>> getFlocks() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoints.flocks);

      final data = response.data as List<dynamic>;

      return data
          .map((item) => Flock.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw FlockException(
        _extractMessage(error, fallback: 'Could not load flocks.'),
      );
    }
  }

  static Future<Flock> createFlock({
    required String name,
    required String breed,
    required DateTime startDate,
    required int initialBirdCount,
    required int currentBirdCount,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.flocks,
        data: {
          'name': name.trim(),
          'breed': breed.trim(),
          'start_date': _formatDate(startDate),
          'initial_bird_count': initialBirdCount,
          'current_bird_count': currentBirdCount,
          'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
        },
      );

      return Flock.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw FlockException(
        _extractMessage(error, fallback: 'Could not create flock.'),
      );
    }
  }

  static Future<Flock> updateFlock({
    required String flockId,
    String? name,
    String? breed,
    DateTime? startDate,
    int? currentBirdCount,
    String? status,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) {
        data['name'] = name.trim();
      }

      if (breed != null) {
        data['breed'] = breed.trim();
      }

      if (startDate != null) {
        data['start_date'] = _formatDate(startDate);
      }

      if (currentBirdCount != null) {
        data['current_bird_count'] = currentBirdCount;
      }

      if (status != null) {
        data['status'] = status;
      }

      if (notes != null) {
        data['notes'] = notes.trim();
      }

      final response = await ApiClient.dio.patch(
        '${ApiEndpoints.flocks}/$flockId',
        data: data,
      );

      return Flock.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw FlockException(
        _extractMessage(error, fallback: 'Could not update flock.'),
      );
    }
  }

  static Future<Flock> getFlock(String flockId) async {
    try {
      final response = await ApiClient.dio.get(
        '${ApiEndpoints.flocks}/$flockId',
      );

      return Flock.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw FlockException(
        _extractMessage(error, fallback: 'Could not load flock details.'),
      );
    }
  }

  static Future<void> deleteFlock(String flockId) async {
    try {
      await ApiClient.dio.delete('${ApiEndpoints.flocks}/$flockId');
    } on DioException catch (error) {
      throw FlockException(
        _extractMessage(error, fallback: 'Could not delete flock.'),
      );
    }
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String _extractMessage(
    DioException error, {
    required String fallback,
  }) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];

      if (detail is String) {
        return detail;
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Could not connect to the PoultryGuard server.';
    }

    return fallback;
  }
}

class FlockException implements Exception {
  const FlockException(this.message);

  final String message;

  @override
  String toString() => message;
}
