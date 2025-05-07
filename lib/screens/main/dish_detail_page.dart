import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import '../../backend/repositories/dish_repository_impl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DishDetailPage extends StatefulWidget {
  final Map<String, dynamic> dish;
  const DishDetailPage({super.key, required this.dish});

  @override
  State<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _tutorialLinkController;
  List<Map<String, dynamic>> _ingredients = [];
  final _ingredientController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  final _dishRepository = DishRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dish['name']);
    _descriptionController = TextEditingController(text: widget.dish['description'] ?? '');
    _prepTimeController = TextEditingController(text: widget.dish['prepTime'].toString());
    _cookTimeController = TextEditingController(text: widget.dish['cookTime'].toString());
    _servingsController = TextEditingController(text: widget.dish['servings'].toString());
    _tutorialLinkController = TextEditingController(text: widget.dish['tutorialLink'] ?? '');
    _ingredients = List<Map<String, dynamic>>.from(widget.dish['ingredients'] ?? []);
    if (widget.dish['photoPath'] != null && File(widget.dish['photoPath']).existsSync()) {
      _selectedImage = File(widget.dish['photoPath']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _tutorialLinkController.dispose();
    _ingredientController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        _ingredients.add({
          'name': _ingredientController.text,
          'price': double.parse(_priceController.text),
        });
        _ingredientController.clear();
        _priceController.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty || _prepTimeController.text.isEmpty || _cookTimeController.text.isEmpty ||
        _servingsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir les champs obligatoires')),
      );
      return;
    }

    final dishData = {
      'id': widget.dish['id'],
      'name': _nameController.text,
      'description': _descriptionController.text,
      'prepTime': int.parse(_prepTimeController.text),
      'cookTime': int.parse(_cookTimeController.text),
      'servings': int.parse(_servingsController.text),
      'tutorialLink': _tutorialLinkController.text.isNotEmpty ? _tutorialLinkController.text : null,
      'ingredients': _ingredients,
      'photoPath': _selectedImage?.path ?? widget.dish['photoPath'],
    };

    await _dishRepository.saveDish(dishData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modifications enregistrées avec succès')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du plat'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: whiteColor),
            onPressed: _saveChanges,
          ),
        ],
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
                      'Détails du plat',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du plat',
                        prefixIcon: const Icon(Icons.fastfood, color: tealColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description, color: tealColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _prepTimeController,
                            decoration: InputDecoration(
                              labelText: 'Temps de préparation (min)',
                              prefixIcon: const Icon(Icons.timer, color: tealColor),
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
                            controller: _cookTimeController,
                            decoration: InputDecoration(
                              labelText: 'Temps de cuisson (min)',
                              prefixIcon: const Icon(Icons.timer, color: tealColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _servingsController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de portions',
                        prefixIcon: const Icon(Icons.people, color: tealColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _tutorialLinkController,
                      decoration: InputDecoration(
                        labelText: 'Lien tutoriel (optionnel)',
                        prefixIcon: const Icon(Icons.link, color: tealColor),
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
                      'Ingrédients',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientController,
                            decoration: InputDecoration(
                              labelText: 'Ingrédient',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Prix (€)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _addIngredient,
                        child: const Text(
                          'Ajouter un autre ingrédient',
                          style: TextStyle(color: tealColor),
                        ),
                      ),
                    ),
                    if (_ingredients.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text('Liste des ingrédients :'),
                      ..._ingredients.map((ingredient) => ListTile(
                            title: Text('${ingredient['name']} - ${ingredient['price']} €'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _ingredients.remove(ingredient);
                                });
                              },
                            ),
                          )).toList(),
                    ],
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
                      'Photo du plat (optionnel)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 150)
                            : widget.dish['photoPath'] != null && File(widget.dish['photoPath']).existsSync()
                                ? Image.file(File(widget.dish['photoPath']), fit: BoxFit.cover, width: double.infinity, height: 150)
                                : const Text('Aucune photo sélectionnée'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tealColor,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Modifier la photo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
