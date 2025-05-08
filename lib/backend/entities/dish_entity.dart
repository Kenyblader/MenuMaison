class DishEntity {
  final int? id;
  final String name;
  final String description;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String? tutorialLink;
  final List<Map<String, dynamic>>
  ingredients; // [ {name: String, quantity: int, unit: String} ]
  int synced; // État de synchronisation
  int lastUpdated;
  final String? photoPath;

  DishEntity({
    this.id,
    required this.name,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    this.tutorialLink,
    required this.ingredients,
    this.photoPath,
    this.lastUpdated = 0,
    this.synced = 0,
  });

  factory DishEntity.fromMap(Map<String, dynamic> map) {
    return DishEntity(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      servings: map['servings'],
      tutorialLink: map['tutorialLink'],
      ingredients: map['ingredients'],
      photoPath: map['photoPath'],
      synced: map['synced'] ?? 0,
      lastUpdated: map['lastUpdated'] ?? 0,
    );
  }

  // Conversion pour SQLite
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
      'synced': synced,
      'lastUpdated': lastUpdated,
    };
  }

  // Conversion depuis API
  factory DishEntity.fromJson(Map<String, dynamic> json) {
    return DishEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      prepTime: json['prepTime'],
      cookTime: json['cookTime'],
      servings: json['servings'],
      tutorialLink: json['tutorialLink'],
      ingredients: json['ingredients'],
      photoPath: json['photoPath'],
      synced: 1, // Considéré comme synchronisé car venant du serveur
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Conversion pour API
  Map<String, dynamic> toJson() {
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
}
