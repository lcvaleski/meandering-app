class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.token,
  });

  final String email;
  final String token;
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
      token: map['stream_token'],
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
    token: '',
    id: '1');
final kMockStudent = UserModel(
    email: 'nr@getstream.io',
    token: '',
    id: '2');
