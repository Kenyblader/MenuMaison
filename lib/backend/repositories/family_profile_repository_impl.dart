import 'package:sqflite/sqflite.dart';
import '../entities/family_profile_entity.dart';
import '../models/family_profile_model.dart';
import '../database/database_helper.dart';
import 'family_profile_repository.dart';

class FamilyProfileRepositoryImpl implements FamilyProfileRepository {
  static final FamilyProfileRepositoryImpl _instance =
      FamilyProfileRepositoryImpl._internal();
  factory FamilyProfileRepositoryImpl() => _instance;
  FamilyProfileRepositoryImpl._internal();

  static const String _tableFamilyProfiles = 'family_profiles';
  get _db async => await DatabaseHelper().database;

  @override
  Future<bool> isProfileConfigured() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> profiles = await db.query(
      _tableFamilyProfiles,
    );
    return profiles.isNotEmpty;
  }

  @override
  Future<void> saveProfile(FamilyProfileModel profile) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      _tableFamilyProfiles,
      FamilyProfileEntity(
        totalMembers: profile.totalMembers,
        adults: profile.adults,
        children: profile.children,
        babies: profile.babies,
        dietaryRestrictions: profile.dietaryRestrictions,
        region: profile.region,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<FamilyProfileModel?> getProfile() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> profiles = await db.query(
      _tableFamilyProfiles,
    );
    if (profiles.isNotEmpty) {
      return FamilyProfileModel.fromEntity(
        FamilyProfileEntity.fromMap(profiles.first),
      );
    }
    return null;
  }

  Future<List<FamilyProfileEntity>> getUnsyncedFamilyProfiles() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableFamilyProfiles,
      where: 'synced = ?',
      whereArgs: [0],
    );
    return List.generate(
      maps.length,
      (i) => FamilyProfileEntity.fromMap(maps[i]),
    );
  }

  Future<void> updateFamilyProfileWithServerId(
    int localId,
    int serverId,
  ) async {
    final db = await _db;
    await db.update(
      _tableFamilyProfiles,
      {'id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markFamilyProfileSynced(int localId) async {
    final db = await _db;
    await db.update(
      _tableFamilyProfiles,
      {'synced': 1},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }
}
