import 'package:sqflite/sqflite.dart';
import '../entities/user_entity.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static final AuthRepositoryImpl _instance = AuthRepositoryImpl._internal();
  factory AuthRepositoryImpl() => _instance;
  AuthRepositoryImpl._internal();

  static const String _tableUsers = 'users';
  static const String _tableSessions = 'sessions';

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<void> init() async {
    // Rien à faire ici pour l'instant
  }

  @override
  Future<bool> register(String email, String password, {String? name}) async {
    final db = await _db;
    final userEntity = UserEntity(
      email: email,
      password: password, // À sécuriser avec un hash dans une version future
      name: name ?? '', // Valeur par défaut si name est null
    );
    try {
      await db.insert(_tableUsers, userEntity.toMap());
      return true;
    } catch (e) {
      return false; // Retourne false en cas d'erreur (ex. email déjà utilisé)
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    final db = await _db;
    final List<Map<String, dynamic>> users = await db.query(
      _tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (users.isNotEmpty) {
      final user = UserModel.fromEntity(UserEntity.fromMap(users.first));
      if (user.id != null) {
        await startSession(user.id!); // Utilisation de ! car id est validé
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> startSession(int userId) async {
    final db = await _db;
    await db.delete(_tableSessions); // Supprime les sessions existantes
    await db.insert(_tableSessions, {'id': 1, 'userId': userId});
  }

  @override
  Future<void> logout() async {
    final db = await _db;
    await db.delete(_tableSessions);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final db = await _db;
    final List<Map<String, dynamic>> sessions = await db.query(_tableSessions);
    if (sessions.isNotEmpty) {
      final userId = sessions.first['userId'] as int?;
      if (userId != null) {
        final List<Map<String, dynamic>> users = await db.query(
          _tableUsers,
          where: 'id = ?',
          whereArgs: [userId],
        );
        if (users.isNotEmpty) {
          return UserModel.fromEntity(UserEntity.fromMap(users.first));
        }
      }
    }
    return null;
  }
}
