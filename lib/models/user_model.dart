class UserModel {
  UserModel({
    required this.id,
    required this.email,
  });

  final String email;
  final String id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
    );
  }
}

class UserLoginModel {
  UserLoginModel({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}



class UserRegistrationModel {
  final String email;
  final String password;

  UserRegistrationModel({
    required this.password,
    required this.email,
  });
}

final kMockTeacher = UserModel(
    email: 'logan@coventrylabs.net',
    id: '1');
final kMockStudent = UserModel(
    email: 'jud@coventrylabs.net',
    id: '2');