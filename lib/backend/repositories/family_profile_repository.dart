import '../models/family_profile_model.dart';

abstract class FamilyProfileRepository {
  Future<bool> isProfileConfigured();
  Future<void> saveProfile(FamilyProfileModel profile);
  Future<FamilyProfileModel?> getProfile();
}
