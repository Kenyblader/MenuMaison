import '../entities/user_entity.dart';

class UserModel {
  final int? id;
  final String email;
  final String? name;

  UserModel({this.id, required this.email, this.name});

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(id: entity.id, email: entity.email, name: entity.name);
  }
}
