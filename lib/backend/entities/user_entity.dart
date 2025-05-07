class UserEntity {
  final int? id;
  final String email;
  final String password;
  final String? name;

  UserEntity({this.id, required this.email, required this.password, this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
    };
  }

  static UserEntity fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
    );
  }
}
