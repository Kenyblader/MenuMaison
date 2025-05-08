class FamilyProfileEntity {
  final int? id;
  final int totalMembers;
  final int adults;
  final int children;
  final int babies;
  final String? dietaryRestrictions;
  final String? region;
  int synced; // État de synchronisation
  int lastUpdated;

  FamilyProfileEntity({
    this.id,
    required this.totalMembers,
    required this.adults,
    required this.children,
    required this.babies,
    this.dietaryRestrictions,
    this.region,
    this.synced = 0,
    this.lastUpdated = 0,
  });

  factory FamilyProfileEntity.fromMap(Map<String, dynamic> map) {
    return FamilyProfileEntity(
      id: map['id'],
      totalMembers: map['totalMembers'],
      adults: map['adults'],
      children: map['children'],
      babies: map['babies'],
      dietaryRestrictions: map['dietaryRestrictions'],
      region: map['region'],
      synced: map['synced'] ?? 0,
      lastUpdated: map['lastUpdated'] ?? 0,
    );
  }

  // Conversion pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalMembers': totalMembers,
      'adults': adults,
      'children': children,
      'babies': babies,
      'dietaryRestrictions': dietaryRestrictions,
      'region': region,
      'synced': synced,
      'lastUpdated': lastUpdated,
    };
  }

  // Conversion depuis API
  factory FamilyProfileEntity.fromJson(Map<String, dynamic> json) {
    return FamilyProfileEntity(
      id: json['id'],
      totalMembers: json['totalMembers'],
      adults: json['adults'],
      children: json['children'],
      babies: json['babies'],
      dietaryRestrictions: json['dietaryRestrictions'],
      region: json['region'],
      synced: 1, // Considéré comme synchronisé car venant du serveur
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Conversion pour API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalMembers': totalMembers,
      'adults': adults,
      'children': children,
      'babies': babies,
      'dietaryRestrictions': dietaryRestrictions,
      'region': region,
    };
  }
}
