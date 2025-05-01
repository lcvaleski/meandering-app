import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'services.dart';
import '../utils.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _emailKey = 'auth_email';

  final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
    url: 'meandering://auth', // Custom URL scheme for deep linking
    handleCodeInApp: true,
    androidPackageName: 'net.coventry.sleepless',
    iOSBundleId: 'net.coventry.sleepless',
  );

  // Add method to store email during sign-in process
  Future<void> _storeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // Add method to retrieve stored email
  Future<String?> _getStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Add method to clear stored email
  Future<void> _clearStoredEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
  }

  // Add method to handle the email sign-in link
  Future<bool> handleEmailLink(String emailLink) async {
    try {
      if (_auth.isSignInWithEmailLink(emailLink)) {
        // Get the email from storage
        final email = await _getStoredEmail();
        if (email == null) {
          throw Exception('No email found for verification');
        }

        // Complete sign in
        final userCredential = await _auth.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );

        if (userCredential.user != null) {
          // Identify user with RevenueCat
          await identifyRevenueCatUser(userCredential.user!.uid);
          // Clear the stored email
          await _clearStoredEmail();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error handling email link: $e');
      return false;
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      final UserRegistrationModel user,
      ) async {
    try {
      // Store the email for later use
      await _storeEmail(user.email);

      // Send sign in link to email
      await _auth.sendSignInLinkToEmail(
        email: user.email,
        actionCodeSettings: actionCodeSettings,
      );

      // Return a temporary user model - actual authentication will happen when they click the link
      return UserModel(
        id: 'pending',
        email: user.email,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'operation-not-allowed':
          throw Exception('Email link authentication is not enabled.');
        default:
          throw Exception(e.message ?? 'An error occurred during sign up.');
      }
    }
  }

  @override
  Future<UserModel> logInWithEmailAndPassword(
      final String email,
      final String password,
      ) async {
    try {
      // Store the email for later use
      await _storeEmail(email);

      // Send sign in link to email
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      // Return a temporary user model - actual authentication will happen when they click the link
      return UserModel(
        id: 'pending',
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'operation-not-allowed':
          throw Exception('Email link authentication is not enabled.');
        default:
          throw Exception(e.message ?? 'An error occurred during login.');
      }
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Log out from RevenueCat before Firebase
      await logoutRevenueCatUser();
      await _auth.signOut(); // Sign out from Firebase
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserModel?> checkForExistingUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Identify user with RevenueCat
      await identifyRevenueCatUser(user.uid);

      return UserModel(
        id: user.uid,
        email: user.email!,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}