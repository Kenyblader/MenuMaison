import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  double _budget = 20.0;
  int _numberOfPeople = 4;
  String _preference = 'Aucune';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions intelligentes'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paramètres de suggestion',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Budget (€)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _budget.toString()),
                      onChanged: (value) {
                        setState(() {
                          _budget = double.tryParse(value) ?? _budget;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nombre de personnes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _numberOfPeople.toString()),
                      onChanged: (value) {
                        setState(() {
                          _numberOfPeople = int.tryParse(value) ?? _numberOfPeople;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _preference,
                      decoration: InputDecoration(
                        labelText: 'Préférence',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Aucune', child: Text('Aucune')),
                        DropdownMenuItem(value: 'Végétarien', child: Text('Végétarien')),
                        DropdownMenuItem(value: 'Sans gluten', child: Text('Sans gluten')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _preference = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Simule la génération de suggestions
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tealColor,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Générer des suggestions', style: TextStyle(fontSize: 16)),
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
                      'Suggestions de menus',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildSuggestionCard('Menu 1: Pasta & Salad', '10€', 'Végétarien'),
                    _buildSuggestionCard('Menu 2: Chicken & Rice', '15€', 'Sans gluten'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ), 
    );
  }

  Widget _buildSuggestionCard(String title, String cost, String preference) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text('Coût: $cost | Préférence: $preference'),
        trailing: IconButton(
          icon: const Icon(Icons.add, color: tealColor),
          onPressed: () {
            // Ajoute le menu au planning (simulé)
          },
        ),
      ),
    );
  }
}
