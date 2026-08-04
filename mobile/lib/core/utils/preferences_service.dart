import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static const String _languageKey = 'selected_language';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static Future<void> saveLanguage(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_languageKey, languageCode);
  }

  static Future<String?> getLanguage() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_languageKey);
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_onboardingCompletedKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_onboardingCompletedKey) ?? false;
  }
}
