class RegistrationDraft {
  RegistrationDraft._();

  static String? phoneNumber;
  static String? password;
  static String preferredLanguage = 'en';
  static String role = 'farmer';
  static String? firebaseIdToken;

  static bool get isComplete {
    return phoneNumber != null &&
        password != null &&
        firebaseIdToken != null &&
        phoneNumber!.isNotEmpty &&
        password!.isNotEmpty &&
        firebaseIdToken!.isNotEmpty;
  }

  static void clear() {
    phoneNumber = null;
    password = null;
    firebaseIdToken = null;
    preferredLanguage = 'en';
    role = 'farmer';
  }
}
