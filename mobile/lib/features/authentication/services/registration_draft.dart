class RegistrationDraft {
  RegistrationDraft._();

  static String? phoneNumber;
  static String? password;
  static String preferredLanguage = 'en';
  static String role = 'farmer';

  static bool get isComplete {
    return phoneNumber != null &&
        password != null &&
        phoneNumber!.isNotEmpty &&
        password!.isNotEmpty;
  }

  static void clear() {
    phoneNumber = null;
    password = null;
    preferredLanguage = 'en';
    role = 'farmer';
  }
}
