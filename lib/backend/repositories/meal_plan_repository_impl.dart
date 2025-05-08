import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu_maison/backend/database/database_helper.dart';
import 'package:menu_maison/backend/entities/meal_plan.entity.dart';
import 'package:menu_maison/backend/repositories/meal_plan_repository.dart';
import 'package:menu_maison/utils/auth_state.dart';
import 'package:sqflite/sqflite.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  Future<Database> get _db async => await DatabaseHelper().database;
  final String _table = "meal_plans";
  final int userId = AuthState.userId ?? 0;

  @override
  Future<void> deleteMealPlan(int id) async {
    final db = await _db;
    return db
        .delete(_table, where: 'id= ?', whereArgs: [id])
        .then((onValue) {
          return Future.value();
        })
        .onError((e, st) {
          print("erreur de suppression: $e");
          return Future.error('erreur sqlite');
        });
  }

  @override
  Future<List<MealPlan>> getMealPlan() async {
    final db = await _db;
    final data = await db.query(_table);
    return data.map((e) => MealPlan.fromMap(e)).toList();
  }

  @override
  Future<void> saveMealPlan(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert(_table, data);
    return Future.value();
  }

  @override
  Future<void> updateMealPlan(MealPlan pdated) {
    return _db.then((db) {
      return db
          .update(
            _table,
            pdated.toMap(),
            where: 'id = ?',
            whereArgs: [pdated.id],
          )
          .then((_) {
            return Future.value();
          })
          .onError((e, st) {
            print("Erreur de mise à jour: $e");
            return Future.error('erreur sqlite');
          });
    });
  }
}
