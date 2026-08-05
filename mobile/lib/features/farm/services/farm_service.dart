import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class FarmService {
  FarmService._();

  static Future<void> createFarm({
    required String farmName,
    required String address,
    required int birdCapacity,
    String? latitude,
    String? longitude,
    required bool sensorAlerts,
    required bool diseaseAlerts,
    required bool communityAlerts,
  }) async {
    try {
      await ApiClient.dio.post(
        ApiEndpoints.farms,
        data: {
          'farm_name': farmName,
          'address': address,
          'bird_capacity': birdCapacity,
          'latitude': latitude,
          'longitude': longitude,
          'sensor_alerts': sensorAlerts,
          'disease_alerts': diseaseAlerts,
          'community_alerts': communityAlerts,
        },
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];

        if (detail is String) {
          throw FarmException(detail);
        }
      }

      if (error.type == DioExceptionType.connectionError) {
        throw const FarmException(
          'Could not connect to the PoultryGuard server.',
        );
      }

      throw const FarmException('Farm registration failed. Please try again.');
    }
  }
}

class FarmException implements Exception {
  const FarmException(this.message);

  final String message;

  @override
  String toString() => message;
}
