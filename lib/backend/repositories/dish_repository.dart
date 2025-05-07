
abstract class DishRepository {
  Future<void> saveDish(Map<String, dynamic> dish);
  Future<List<Map<String, dynamic>>> getDishes();
  Future<void> deleteDish(int id);
}
