class PasswordResetDraft {
  PasswordResetDraft._();

  static String? phoneNumber;
  static String? firebaseIdToken;

  static bool get isVerified {
    return phoneNumber != null &&
        firebaseIdToken != null &&
        phoneNumber!.isNotEmpty &&
        firebaseIdToken!.isNotEmpty;
  }

  static void clear() {
    phoneNumber = null;
    firebaseIdToken = null;
  }
}
