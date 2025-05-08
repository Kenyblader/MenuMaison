import 'package:menu_maison/backend/entities/meal_plan.entity.dart';

abstract class MealPlanRepository {
  Future<void> saveMealPlan(Map<String, dynamic> data);
  Future<List<MealPlan>> getMealPlan();
  Future<void> deleteMealPlan(int id);
  Future<void> updateMealPlan(MealPlan pdated);
}
