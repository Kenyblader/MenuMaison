import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'add_dish_page.dart';
import 'dish_detail_page.dart';
import '../../backend/repositories/dish_repository_impl.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> _shareDishAsPDF(BuildContext context, Map<String, dynamic> dish) async {
    print('Génération du PDF pour le plat: ${dish['name']}');

    final pdf = pw.Document();

    // Calcul du temps total
    final totalTime = (dish['prepTime'] as int? ?? 0) + (dish['cookTime'] as int? ?? 0);

    // Extraction des ingrédients
    final ingredients = List<Map<String, dynamic>>.from(dish['ingredients'] ?? []);
    final totalCost = ingredients.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] as double? ?? 0.0),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Détails du plat : ${dish['name']}',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Description : ${dish['description'] ?? 'Non spécifiée'}',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Temps total : $totalTime min',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Portions : ${dish['servings'] ?? 0} personnes',
              style: pw.TextStyle(fontSize: 16),
            ),
            if (dish['tutorialLink'] != null && dish['tutorialLink'].toString().isNotEmpty)
              pw.Text(
                'Lien du tutoriel : ${dish['tutorialLink']}',
                style: pw.TextStyle(fontSize: 16),
              ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Ingrédients :',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Nom',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Prix',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...ingredients.map(
                  (item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item['name']?.toString() ?? ''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${(item['price'] as double? ?? 0.0).toStringAsFixed(2)} €'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Coût total des ingrédients : ${totalCost.toStringAsFixed(2)} €',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/plat_${dish['name'].replaceAll(' ', '_')}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    final result = await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Voici les détails du plat "${dish['name']}" en PDF.',
      subject: 'Détails du plat : ${dish['name']}',
    );

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plat partagé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du partage du plat')),
      );
    }
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
          
          const SizedBox(height: 20),
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
                final dish = dishes.firstWhere((d) => d['id'] == id);
                _shareDishAsPDF(context, dish);
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
                _loadDishes();
              }
            });
          }
        },
      ),
    );
  }
}
