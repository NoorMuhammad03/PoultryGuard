import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/medication_guidance.dart';
import '../models/dosage_calculation.dart';

class MedicationService {
  MedicationService._();

  static Future<List<MedicationGuidance>> getGuidanceByDisease(
    String disease,
  ) async {
    try {
      final response = await ApiClient.dio.get(
        '${ApiEndpoints.medications}/disease/$disease',
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => MedicationGuidance.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw MedicationException(
        _extractMessage(error, fallback: 'Could not load medication guidance.'),
      );
    }
  }

  static Future<DosageCalculation> calculateDosage({
    required String medicationId,
    required int birdCount,
    required double averageWeightKg,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '${ApiEndpoints.medications}/$medicationId/calculate',
        data: {'bird_count': birdCount, 'average_weight_kg': averageWeightKg},
      );

      return DosageCalculation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw MedicationException(
        _extractMessage(
          error,
          fallback: 'Could not calculate medication dosage.',
        ),
      );
    }
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

class MedicationException implements Exception {
  const MedicationException(this.message);

  final String message;

  @override
  String toString() => message;
}
