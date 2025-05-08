import 'package:flutter/material.dart';
import 'package:menu_maison/screens/main/map_page.dart';
import 'package:menu_maison/utils/location.dart';
import 'package:menu_maison/utils/theme.dart';
import 'home_page.dart';
import '../../backend/models/family_profile_model.dart';
import '../../backend/repositories/family_profile_repository_impl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _totalMembersController = TextEditingController();
  final _adultsController = TextEditingController();
  final _childrenController = TextEditingController();
  final _babiesController = TextEditingController();
  final _dietaryRestrictionsController = TextEditingController();
  String? _region;
  final _familyProfileRepository = FamilyProfileRepositoryImpl();
  late FamilyProfileModel existingProfile;

  @override
  void dispose() {
    _totalMembersController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _babiesController.dispose();
    _dietaryRestrictionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProfile();
  }

  _loadProfile() async {
    final prof = await _familyProfileRepository.getProfile();
    existingProfile = prof as FamilyProfileModel;
    _totalMembersController.text = existingProfile.totalMembers.toString();
    _adultsController.text = existingProfile.adults.toString();
    _babiesController.text = existingProfile.babies.toString();
    _childrenController.text = existingProfile.children.toString();
    _dietaryRestrictionsController.text =
        existingProfile.dietaryRestrictions ?? '';
    _region = existingProfile.region;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurer le profil familial'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Composition familiale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _totalMembersController,
                      decoration: InputDecoration(
                        labelText: 'Nombre total de membres',
                        prefixIcon: const Icon(Icons.group, color: tealColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _adultsController,
                            decoration: InputDecoration(
                              labelText: 'Adultes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _childrenController,
                            decoration: InputDecoration(
                              labelText: 'Enfants',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _babiesController,
                            decoration: InputDecoration(
                              labelText: 'Bébés',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Préférences alimentaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dietaryRestrictionsController,
                      decoration: InputDecoration(
                        labelText: 'Restrictions (ex. végétarien, sans gluten)',
                        prefixIcon: const Icon(
                          Icons.local_dining,
                          color: tealColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Région géographique',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (builder) => MapScreen(function: _updateRegion),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tealColor,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Selectionner un lieux',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _region ?? 'aucune region n est selectionner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final totalMembers =
                    int.tryParse(_totalMembersController.text) ?? 0;
                final adults = int.tryParse(_adultsController.text) ?? 0;
                final children = int.tryParse(_childrenController.text) ?? 0;
                final babies = int.tryParse(_babiesController.text) ?? 0;

                if (totalMembers != (adults + children + babies)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Le total des membres doit correspondre à la somme des adultes, enfants et bébés.',
                      ),
                    ),
                  );
                  return;
                }

                final profile = FamilyProfileModel(
                  id: existingProfile.id,
                  totalMembers: totalMembers,
                  adults: adults,
                  children: children,
                  babies: babies,
                  dietaryRestrictions:
                      _dietaryRestrictionsController.text.isNotEmpty
                          ? _dietaryRestrictionsController.text
                          : null,
                  region: _region,
                );
                try {
                  await _familyProfileRepository.updateProfile(profile);
                  await _loadProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("mise a jour reussit")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("erreur lors de la mise a jour")),
                  );
                  print("erreur updare profil: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tealColor,
                foregroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Enregistrer et continuer',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _updateRegion(String position) {
    setState(() {
      _region = position;
    });
  }
}
