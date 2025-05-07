import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'add_dish_page.dart';
import 'dish_detail_page.dart';
import '../../backend/repositories/dish_repository_impl.dart';
import 'dart:io';

class DishManagementPage extends StatefulWidget {
  const DishManagementPage({super.key});

  @override
  State<DishManagementPage> createState() => _DishManagementPageState();
}

class _DishManagementPageState extends State<DishManagementPage> {
  final DishRepositoryImpl _dishRepository = DishRepositoryImpl();
  List<Map<String, dynamic>> dishes = [];

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    final loadedDishes = await _dishRepository.getDishes();
    setState(() {
      dishes = loadedDishes;
    });
  }

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
          ...dishes.map((dish) => _buildDishCard(
                dish['name'],
                '${dish['prepTime'] + dish['cookTime']} min',
                '${dish['servings']} personnes',
                dish['id'],
                dish['photoPath'],
              )).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-dish');
          if (result == true) {
            _loadDishes();
          }
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

  Widget _buildDishCard(String name, String time, String servings, int? id, String? photoPath) {
    return Card(
      child: ListTile(
        leading: photoPath != null && File(photoPath).existsSync()
            ? CircleAvatar(
                backgroundImage: FileImage(File(photoPath)),
              )
            : const CircleAvatar(
                backgroundColor: tealColor,
                child: Icon(Icons.fastfood, color: whiteColor),
              ),
        title: Text(name),
        subtitle: Text('$time • $servings'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share, color: tealColor),
              onPressed: () {
                // Logique de partage ici
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                if (id != null) {
                  _dishRepository.deleteDish(id);
                  _loadDishes();
                }
              },
            ),
          ],
        ),
        onTap: () {
          if (id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DishDetailPage(dish: Map<String, dynamic>.from(dishes.firstWhere((d) => d['id'] == id))),
              ),
            ).then((value) {
              if (value == true) {
                _loadDishes(); // Rafraîchir la liste après modification
              }
            });
          }
        },
      ),
    );
  }
}
