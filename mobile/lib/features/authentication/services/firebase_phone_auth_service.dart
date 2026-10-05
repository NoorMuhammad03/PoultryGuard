import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebasePhoneAuthService {
  FirebasePhoneAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static ConfirmationResult? _webConfirmationResult;
  static String? _verificationId;

  static Future<void> sendOtp({required String phoneNumber}) async {
    if (kIsWeb) {
      _webConfirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (error) {
        throw FirebasePhoneAuthException(
          error.message ?? 'Phone verification failed.',
        );
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  static Future<void> verifyOtp({required String otp}) async {
    try {
      if (kIsWeb) {
        final confirmationResult = _webConfirmationResult;

        if (confirmationResult == null) {
          throw const FirebasePhoneAuthException(
            'Verification session not found. Please resend the code.',
          );
        }

        await confirmationResult.confirm(otp);
        return;
      }

      final verificationId = _verificationId;

      if (verificationId == null) {
        throw const FirebasePhoneAuthException(
          'Verification session not found. Please resend the code.',
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw FirebasePhoneAuthException(
        error.message ?? 'Invalid verification code.',
      );
    }
  }

  static Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    _webConfirmationResult = null;
    _verificationId = null;
  }
}

class FirebasePhoneAuthException implements Exception {
  const FirebasePhoneAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
