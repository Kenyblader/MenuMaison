import 'package:flutter/material.dart';
import 'package:menu_maison/components/gemini_progress_animation.dart';
import 'package:menu_maison/services/gemini_service.dart';
import 'package:menu_maison/utils/theme.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _numberOfPeopleController =
      TextEditingController();
  String? _preference;
  final gemini = Geminservice();
  final List<DishModel> suggestDishes = [];

  _getSuggestions() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
              child: GeminiProcessingAnimation(
                future: gemini.GetMEnuByBudget(
                  _budgetController.text,
                  int.parse(_numberOfPeopleController.text),
                  _preference ?? 'Aucune',
                ),
                onCompleted: (result) {
                  setState(() {
                    Navigator.of(context).pop();
                    suggestDishes.clear();
                    suggestDishes.addAll(result);
                  });
                },
                onError: (error) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("desole une erreur c'est produite")),
                  );
                },
              ),
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la récupération des suggestions : $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions intelligentes'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
        leading: Builder(
          builder:
              (context) => IconButton(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Budget (CFA)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: _budgetController,
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
                      controller: _numberOfPeopleController,
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
                        DropdownMenuItem(
                          value: 'Aucune',
                          child: Text('Aucune'),
                        ),
                        DropdownMenuItem(
                          value: 'Végétarien',
                          child: Text('Végétarien'),
                        ),
                        DropdownMenuItem(
                          value: 'Sans gluten',
                          child: Text('Sans gluten'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _preference = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_budgetController.text.isEmpty ||
                            _numberOfPeopleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez remplir tous les champs'),
                            ),
                          );
                          return;
                        }
                        _getSuggestions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tealColor,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Générer des suggestions',
                        style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
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
                      'Suggestions de menus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    suggestDishes.isEmpty
                        ? const Center(
                          child: Text(
                            'Aucune suggestion disponible',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggestDishes.length,
                          itemBuilder: (context, index) {
                            final dish = suggestDishes[index];
                            return _buildSuggestionCard(
                              dish.name,
                              '${dish.total} CFA',
                              _preference ?? 'Aucune',
                            );
                          },
                        ),
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
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
        subtitle: Text(
          'Coût : $cost | Préférence : $preference',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add, color: tealColor),
          onPressed: () {
            // Ajoute le menu au planning (à implémenter)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title ajouté au planning')),
            );
          },
        ),
      ),
    );
  }
}
