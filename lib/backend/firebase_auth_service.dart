import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'services.dart';

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