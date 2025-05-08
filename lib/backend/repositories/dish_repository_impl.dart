import 'dart:convert';
import 'package:menu_maison/backend/entities/dish_entity.dart';

import '../database/database_helper.dart';
import 'dish_repository.dart';

class DishRepositoryImpl implements DishRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<void> saveDish(Map<String, dynamic> dish) async {
    final db = await _dbHelper.database;
    final dishData = Map<String, dynamic>.from(dish);

    // Convertir la liste des ingrédients en JSON
    dishData['ingredients'] = jsonEncode(dish['ingredients']);

    if (dishData['id'] != null) {
      await db.update(
        'dishes',
        dishData,
        where: 'id = ?',
        whereArgs: [dishData['id']],
      );
    } else {
      await db.insert('dishes', dishData);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDishes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('dishes');
    return maps.map((map) {
      final dish = Map<String, dynamic>.from(map);
      // Désérialiser les ingrédients depuis JSON
      dish['ingredients'] = jsonDecode(map['ingredients'] ?? '[]');
      return dish;
    }).toList();
  }

  Future<Map<String, dynamic>> getDisheById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dishes',
      where: 'id=?',
      whereArgs: [id],
    );

    final dish = Map<String, dynamic>.from(maps.first);
    // Désérialiser les ingrédients depuis JSON
    dish['ingredients'] = jsonDecode(maps.first['ingredients'] ?? '[]');
    return dish;
  }

  @override
  Future<void> deleteDish(int id) async {
    final db = await _dbHelper.database;
    await db.delete('dishes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDishWithServerId(int localId, int serverId) async {
    final db = await _dbHelper.database;
    await db.update(
      'dishes',
      {'id': serverId},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markDishSynced(int localId) async {
    final db = await _dbHelper.database;
    await db.update(
      'dishes',
      {'synced': 1},
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<List<DishEntity>> getUnsyncedDishes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dishes',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => DishEntity.fromMap(maps[i]));
  }

  Future<List<int>> getAllDishIds() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dishes',
      columns: ['id'],
      where: 'id IS NOT NULL',
    );
    return List.generate(maps.length, (i) => maps[i]['id'] as int);
  }
}
