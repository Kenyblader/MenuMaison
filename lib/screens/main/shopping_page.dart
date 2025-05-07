import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import '../../backend/repositories/dish_repository_impl.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  String _selectedPeriod = 'Hebdomadaire';
  List<Map<String, dynamic>> _ingredients = [];
  final _dishRepository = DishRepositoryImpl();
  final _newItemNameController = TextEditingController();
  final _newItemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final dishes = await _dishRepository.getDishes();
    final Map<String, List<Map<String, dynamic>>> groupedIngredients = {};

    // Regrouper les ingrédients par nom
    for (var dish in dishes) {
      final ingredients = List<Map<String, dynamic>>.from(dish['ingredients'] ?? []);
      for (var ingredient in ingredients) {
        final name = ingredient['name'];
        if (!groupedIngredients.containsKey(name)) {
          groupedIngredients[name] = [];
        }
        groupedIngredients[name]!.add({
          'name': name,
          'price': ingredient['price'] ?? 0.0,
        });
      }
    }

    // Calculer la quantité et le coût total pour chaque groupe
    final List<Map<String, dynamic>> uniqueIngredients = [];
    groupedIngredients.forEach((name, ingredientList) {
      final quantity = ingredientList.length;
      final totalCost = ingredientList.fold<double>(
        0.0,
        (sum, item) => sum + (item['price'] as double),
      );
      uniqueIngredients.add({
        'name': name,
        'quantity': quantity,
        'totalCost': totalCost,
      });
    });

    setState(() {
      _ingredients = uniqueIngredients;
    });
  }

  void _addNewItem() {
    if (_newItemNameController.text.isEmpty || _newItemPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      final name = _newItemNameController.text;
      final price = double.parse(_newItemPriceController.text);
      // Vérifier si l'ingrédient existe déjà
      final existingIngredient = _ingredients.firstWhere(
        (ingredient) => ingredient['name'] == name,
        orElse: () => {},
      );
      if (existingIngredient.isNotEmpty) {
        // Si l'ingrédient existe, augmenter la quantité et ajouter au coût total
        existingIngredient['quantity'] += 1;
        existingIngredient['totalCost'] += price;
      } else {
        // Sinon, ajouter un nouvel ingrédient
        _ingredients.add({
          'name': name,
          'quantity': 1,
          'totalCost': price,
        });
      }
      _newItemNameController.clear();
      _newItemPriceController.clear();
    });
  }

  @override
  void dispose() {
    _newItemNameController.dispose();
    _newItemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de courses'),
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
        child: Padding(
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
                        'Période de planification',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Quotidienne', child: Text('Quotidienne')),
                          DropdownMenuItem(value: 'Hebdomadaire', child: Text('Hebdomadaire')),
                          DropdownMenuItem(value: 'Mensuelle', child: Text('Mensuelle')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ingrédients nécessaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      title: Text(ingredient['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantité: ${ingredient['quantity']}'),
                          Text('Coût total: ${ingredient['totalCost'].toStringAsFixed(2)} €'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter un élément',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newItemNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'élément',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newItemPriceController,
                        decoration: InputDecoration(
                          labelText: 'Prix estimé (€)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _addNewItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tealColor,
                            foregroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Ajouter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Liste partagée (simulé)')),
                  );
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
                child: const Text('Partager la liste', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
