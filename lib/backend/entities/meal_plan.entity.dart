class MealPlan {
  final int? id;
  final int userId;
  final DateTime date;
  final String mealType;
  final int dishId;
  int synced; // État de synchronisation
  int lastUpdated;

  MealPlan({
    this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.dishId,
    this.lastUpdated = 0,
    this.synced = 0,
  });

  // Convert a MealPlan into a Map. The keys must correspond to the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'meal_type': mealType,
      'dish_id': dishId,
      'synced': synced,
      'lastUpdated': lastUpdated,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'meal_type': mealType,
      'dish_id': dishId,
    };
  }

  // Extract a MealPlan object from a Map.
  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      mealType: map['meal_type'],
      dishId: map['dish_id'],
      synced: map['synced'] ?? 0,
      lastUpdated: map['lastUpdated'] ?? 0,
    );
  }

  factory MealPlan.fromJson(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      mealType: map['meal_type'],
      dishId: map['dish_id'],
    );
  }
}
