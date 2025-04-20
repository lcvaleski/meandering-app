import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'services.dart';
import '../utils.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        token: '', // You'll need to generate a Stream token here
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
        token: '', // You'll need to generate a Stream token here
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      // Get the authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Google Sign-In failed');
      }

      // Identify user with RevenueCat
      await identifyRevenueCatUser(userCredential.user!.uid);

      return UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        token: '', // You'll need to generate a Stream token here if needed
      );
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Log out from RevenueCat before Firebase
      await logoutRevenueCatUser();
      await _googleSignIn.signOut(); // Sign out from Google
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
        token: '', // You'll need to generate a Stream token here
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
} 