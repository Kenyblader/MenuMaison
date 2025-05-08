import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../../backend/repositories/dish_repository_impl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedPeriod = 'Mois';
  late Future<List<Map<String, dynamic>>> _dishesFuture;
  final DishRepositoryImpl _repository = DishRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dishesFuture = _repository.getDishes();
  }

  // Calcul des plats les plus consommés
  List<MapEntry<String, int>> _getTopDishes(List<Map<String, dynamic>> dishes, [int limit = 5]) {
    final dishCount = <String, int>{};
    for (var dish in dishes) {
      final name = dish['name'] as String? ?? 'Inconnu';
      dishCount[name] = (dishCount[name] ?? 0) + 1;
    }
    return dishCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(limit).toList();
  }

  // Calcul des dépenses par jour pour le mois en cours
  Map<DateTime, double> _getDailyExpenses(List<Map<String, dynamic>> dishes) {
    final dailyExpenses = <DateTime, double>{};
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Initialiser tous les jours du mois à 0
    for (var day = firstDayOfMonth; 
         day.isBefore(lastDayOfMonth) || day.isAtSameMomentAs(lastDayOfMonth); 
         day = day.add(const Duration(days: 1))) {
      dailyExpenses[day] = 0.0;
    }

    // Calculer les dépenses réelles
    for (var dish in dishes) {
      final createdAt = dish['created_at'] != null
          ? DateTime.parse(dish['created_at'] as String)
          : now;
      
      // Ne considérer que le mois en cours
      if (createdAt.month == now.month && createdAt.year == now.year) {
        final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final ingredients = dish['ingredients'] as List<dynamic>;
        double cost = 0.0;
        for (var ingredient in ingredients) {
          cost += (ingredient['price'] as num?)?.toDouble() ?? 0.0;
        }
        dailyExpenses[day] = (dailyExpenses[day] ?? 0.0) + cost;
      }
    }
    
    return dailyExpenses;
  }

  // Calcul des ingrédients les plus utilisés
  List<MapEntry<String, int>> _getTopIngredients(List<Map<String, dynamic>> dishes, [int limit = 5]) {
    final ingredientCount = <String, int>{};
    for (var dish in dishes) {
      final ingredients = dish['ingredients'] as List<dynamic>;
      for (var ingredient in ingredients) {
        final name = ingredient['name'] as String? ?? 'Inconnu';
        ingredientCount[name] = (ingredientCount[name] ?? 0) + 1;
      }
    }
    return ingredientCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
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
            // Section Dépenses (Courbe évolutive)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dépenses du mois en cours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dishesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur lors du chargement des données');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucune donnée disponible');
                        }
                        
                        final dailyExpenses = _getDailyExpenses(snapshot.data!);
                        final entries = dailyExpenses.entries.toList()
                          ..sort((a, b) => a.key.compareTo(b.key));
                        
                        return SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date = entries[value.toInt()].key;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${date.day}',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(value.toInt().toString());
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              minX: 0,
                              maxX: entries.length > 0 ? entries.length - 1 : 0,
                              minY: 0,
                              maxY: entries.isNotEmpty
                                  ? (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.1)
                                  : 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: entries.asMap().entries.map((entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.value,
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: tealColor,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final date = entries[spot.x.toInt()].key;
                                      final amount = entries[spot.x.toInt()].value;
                                      return LineTooltipItem(
                                        'Jour: ${date.day}\nMontant: ${amount.toStringAsFixed(2)} €',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                  getTooltipColor: (spot) => tealColor, // Remplace tooltipBgColor
                                ),
                                handleBuiltInTouches: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Section Ingrédients les plus utilisés (Histogramme)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingrédients les plus utilisés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dishesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur lors du chargement des données');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucune donnée disponible');
                        }
                        
                        final topIngredients = _getTopIngredients(snapshot.data!);
                        
                        return SizedBox(
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: topIngredients.isNotEmpty
                                  ? (topIngredients.first.value.toDouble() * 1.1)
                                  : 10,
                              barGroups: topIngredients.asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.value.toDouble(),
                                      color: _getColor(entry.key),
                                      width: 30,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() < topIngredients.length) {
                                        return Text(
                                          topIngredients[value.toInt()].key,
                                          style: const TextStyle(fontSize: 10),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 50,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(value.toInt().toString());
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Section Plats les plus consommés (Histogramme)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plats les plus consommés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dishesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur lors du chargement des données');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucune donnée disponible');
                        }
                        
                        final topDishes = _getTopDishes(snapshot.data!);
                        
                        return SizedBox(
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: topDishes.isNotEmpty
                                  ? (topDishes.first.value.toDouble() * 1.1)
                                  : 10,
                              barGroups: topDishes.asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.value.toDouble(),
                                      color: _getColor(entry.key + 5), // Différentes couleurs
                                      width: 30,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() < topDishes.length) {
                                        return Text(
                                          topDishes[value.toInt()].key,
                                          style: const TextStyle(fontSize: 10),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 50,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(value.toInt().toString());
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
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

  Color _getColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.cyan,
      Colors.amber,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
