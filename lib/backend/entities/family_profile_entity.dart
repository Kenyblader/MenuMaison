class FamilyProfileEntity {
  final int? id;
  final int totalMembers;
  final int adults;
  final int children;
  final int babies;
  final String? dietaryRestrictions;
  final String? region;

  FamilyProfileEntity({
    this.id,
    required this.totalMembers,
    required this.adults,
    required this.children,
    required this.babies,
    this.dietaryRestrictions,
    this.region,
  });

  Map<String, dynamic> toMap() {
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

  static FamilyProfileEntity fromMap(Map<String, dynamic> map) {
    return FamilyProfileEntity(
      id: map['id'],
      totalMembers: map['totalMembers'],
      adults: map['adults'],
      children: map['children'],
      babies: map['babies'],
      dietaryRestrictions: map['dietaryRestrictions'],
      region: map['region'],
    );
  }
}
