import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'services.dart';
import '../utils.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<void> logout() async {
    try {
      // Log out from RevenueCat before Firebase
      await logoutRevenueCatUser();
      await _auth.signOut();
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