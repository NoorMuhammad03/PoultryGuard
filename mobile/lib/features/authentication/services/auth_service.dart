import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {
  AuthService._();

  static Future<void> register({
    required String phoneNumber,
    required String password,
    required String preferredLanguage,
    required String role,
  }) async {
    try {
      await ApiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'preferred_language': preferredLanguage,
          'role': role,
        },
      );

      // Register currently returns the user, not tokens.
      // Log in immediately to obtain access and refresh tokens.
      await login(
        phoneNumber: phoneNumber,
        password: password,
        rememberMe: true,
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];

        if (detail is String) {
          throw AuthException(detail);
        }
      }

      throw const AuthException('Registration failed. Please try again.');
    }
  }

  static Future<bool> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final rememberMe = preferences.getBool('remember_me') ?? false;

    if (!rememberMe) {
      await TokenStorage.clearTokens();
      return false;
    }

    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        await TokenStorage.clearTokens();
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return true;
    } on DioException {
      await TokenStorage.clearTokens();
      await preferences.setBool('remember_me', false);

      return false;
    }
  }

  static Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await ApiClient.dio.post(
          ApiEndpoints.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } finally {
      final preferences = await SharedPreferences.getInstance();

      await TokenStorage.clearTokens();
      await preferences.setBool('remember_me', false);
    }
  }

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

      final preferences = await SharedPreferences.getInstance();

      await preferences.setBool('remember_me', rememberMe);
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
