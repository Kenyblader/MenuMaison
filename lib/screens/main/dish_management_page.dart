import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'add_dish_page.dart';

class DishManagementPage extends StatelessWidget {
  const DishManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque de plats'),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section des suggestions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggestions de plats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSuggestionCard('Pizza', Icons.local_pizza),
                        _buildSuggestionCard('Pâtes', Icons.food_bank),
                        _buildSuggestionCard('Salade', Icons.local_dining),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Liste des plats de l'utilisateur
          const Text(
            'Mes plats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDishCard('Lasagnes', '45 min', '4 personnes'),
          _buildDishCard('Quiche Lorraine', '30 min', '6 personnes'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-dish');
        },
        backgroundColor: tealColor,
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }

  Widget _buildSuggestionCard(String name, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(right: 10),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: tealColor),
            const SizedBox(height: 5),
            Text(name, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(String name, String time, String servings) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: tealColor,
          child: Icon(Icons.fastfood, color: whiteColor),
        ),
        title: Text(name),
        subtitle: Text('$time • $servings'),
        trailing: IconButton(
          icon: const Icon(Icons.share, color: tealColor),
          onPressed: () {
            // Logique de partage ici
          },
        ),
        onTap: () {
          // Afficher les détails du plat (à implémenter plus tard)
        },
      ),
    );
  }
}
