import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'services.dart';
import '../utils.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isAndroid
        ? '19411767388-h51prlnnii7or8cle558l7kqa879gfvn.apps.googleusercontent.com'
        : null, // iOS uses Info.plist
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      final UserRegistrationModel user,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      // Identify user with RevenueCat
      await identifyRevenueCatUser(userCredential.user!.uid);

      return UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('The email address is already in use by another account.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        case 'weak-password':
          throw Exception('The password is too weak.');
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
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed');
      }

      // Identify user with RevenueCat
      await identifyRevenueCatUser(userCredential.user!.uid);

      return UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
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

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Check if we need re-authentication
      try {
        // This will throw if we need re-authentication
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          await logout();
          throw Exception('Please sign in again before deleting your account');
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to delete account');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In was aborted');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google Sign In failed');
      }

      // Identify user with RevenueCat
      await identifyRevenueCatUser(userCredential.user!.uid);

      return UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
      );
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }
}