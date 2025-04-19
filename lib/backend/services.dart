import '../models/user_model.dart';

abstract class AuthService {
  Future<UserModel> signUpWithEmailAndPassword(
    final UserRegistrationModel user,
  );

  Future<UserModel> logInWithEmailAndPassword(
    final String email,
    final String password,
  );

  Future<void> logout();

  Future<UserModel?> checkForExistingUser();
}

abstract class DatabaseService {
  Future<void> saveUser({
    required final String uid,
    required UserRegistrationModel user,
    required String streamToken,
  });

  Future<UserModel?> retrieveUser({ required final String uid});
}
