abstract final class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';

  static const String currentUser = '/users/me';
  static const String farms = '/farms';
}
