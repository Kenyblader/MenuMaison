class UserEntity {
  final int? id;
  final String email;
  final String password;
  final String? name;
  int synced; // État de synchronisation
  int lastUpdated;

  UserEntity({
    this.id,
    required this.email,
    required this.password,
    this.name,
    this.synced = 0,
    this.lastUpdated = 0,
  });

  // Conversion depuis SQLite
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      synced: map['synced'] ?? 0,
      lastUpdated: map['lastUpdated'] ?? 0,
    );
  }

  // Conversion pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'synced': synced,
      'lastUpdated': lastUpdated,
    };
  }

  // Conversion depuis API
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      email: json['email'],
      password:
          json['password'], // Attention: l'API ne devrait pas renvoyer le mot de passe
      name: json['name'],
      synced: 1, // Considéré comme synchronisé car venant du serveur
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Conversion pour API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password':
          password, // Note: à utiliser seulement pour la création/mise à jour
      'name': name,
    };
  }
}
