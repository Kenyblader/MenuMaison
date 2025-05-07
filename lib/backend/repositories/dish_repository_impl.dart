import 'dart:convert';
import 'package:sqflite/sqflite.dart';
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

  @override
  Future<void> deleteDish(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'dishes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
