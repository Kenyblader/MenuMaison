class Dish {
  final int? id;
  final String name;
  final String? description;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String? tutorialLink;
  final List<Map<String, dynamic>> ingredients; // Maintenant : [{'name': String, 'price': double}]
  final String? photoPath;

  Dish({
    this.id,
    required this.name,
    this.description,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    this.tutorialLink,
    required this.ingredients,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'tutorialLink': tutorialLink,
      'ingredients': ingredients,
      'photoPath': photoPath,
    };
  }

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      servings: map['servings'],
      tutorialLink: map['tutorialLink'],
      ingredients: List<Map<String, dynamic>>.from(map['ingredients'] ?? []),
      photoPath: map['photoPath'],
    );
  }
}
