import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {
  AuthService._();

  static Future<void> login({
    required String phoneNumber,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'remember_me': rememberMe,
        },
      );

      final data = response.data as Map<String, dynamic>;

      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw const AuthException(
          'The server returned an invalid login response.',
        );
      }

      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];

        if (detail is String) {
          throw AuthException(detail);
        }
      }

      if (error.type == DioExceptionType.connectionError) {
        throw const AuthException(
          'Could not connect to the PoultryGuard server.',
        );
      }

      throw const AuthException('Login failed. Please try again.');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
