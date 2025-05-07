import '../models/user_model.dart';
abstract class AuthRepository {
  Future<void> init();
  Future<bool> register(String email, String password, {String? name});
  Future<bool> login(String email, String password);
  Future<void> startSession(int userId);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

