import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'home_page.dart';
import '../../backend/models/family_profile_model.dart';
import '../../backend/repositories/family_profile_repository_impl.dart';

class FamilyProfileSetupPage extends StatefulWidget {
  const FamilyProfileSetupPage({super.key});

  @override
  State<FamilyProfileSetupPage> createState() => _FamilyProfileSetupPageState();
}

class _FamilyProfileSetupPageState extends State<FamilyProfileSetupPage> {
  final _totalMembersController = TextEditingController();
  final _adultsController = TextEditingController();
  final _childrenController = TextEditingController();
  final _babiesController = TextEditingController();
  final _dietaryRestrictionsController = TextEditingController();
  String? _region;
  final _familyProfileRepository = FamilyProfileRepositoryImpl();

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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dietaryRestrictionsController,
                      decoration: InputDecoration(
                        labelText: 'Restrictions (ex. végétarien, sans gluten)',
                        prefixIcon: const Icon(Icons.local_dining, color: tealColor),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      hint: const Text('Sélectionnez une région'),
                      items: const [
                        DropdownMenuItem(value: 'France', child: Text('France')),
                        DropdownMenuItem(value: 'Italie', child: Text('Italie')),
                        DropdownMenuItem(value: 'Espagne', child: Text('Espagne')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _region = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final totalMembers = int.tryParse(_totalMembersController.text) ?? 0;
                final adults = int.tryParse(_adultsController.text) ?? 0;
                final children = int.tryParse(_childrenController.text) ?? 0;
                final babies = int.tryParse(_babiesController.text) ?? 0;

                if (totalMembers != (adults + children + babies)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le total des membres doit correspondre à la somme des adultes, enfants et bébés.')),
                  );
                  return;
                }

                final profile = FamilyProfileModel(
                  totalMembers: totalMembers,
                  adults: adults,
                  children: children,
                  babies: babies,
                  dietaryRestrictions: _dietaryRestrictionsController.text.isNotEmpty ? _dietaryRestrictionsController.text : null,
                  region: _region,
                );
                await _familyProfileRepository.saveProfile(profile);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
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
              child: const Text('Enregistrer et continuer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
