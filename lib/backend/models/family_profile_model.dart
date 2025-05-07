import '../entities/family_profile_entity.dart';

class FamilyProfileModel {
  final int? id;
  final int totalMembers;
  final int adults;
  final int children;
  final int babies;
  final String? dietaryRestrictions;
  final String? region;

  FamilyProfileModel({
    this.id,
    required this.totalMembers,
    required this.adults,
    required this.children,
    required this.babies,
    this.dietaryRestrictions,
    this.region,
  });

  factory FamilyProfileModel.fromEntity(FamilyProfileEntity entity) {
    return FamilyProfileModel(
      id: entity.id,
      totalMembers: entity.totalMembers,
      adults: entity.adults,
      children: entity.children,
      babies: entity.babies,
      dietaryRestrictions: entity.dietaryRestrictions,
      region: entity.region,
    );
  }
}
