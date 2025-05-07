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
  String _selectedPeriod = 'Semaine';
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

  // Calcul des plats les plus consommés par période
  List<MapEntry<String, int>> _getConsumptionData(String period, List<Map<String, dynamic>> dishes) {
    final dishCount = <String, int>{};
    final filteredDishes = dishes.take(_getPeriodLimit(period)).toList();
    for (var dish in filteredDishes) {
      final name = dish['name'] as String? ?? 'Inconnu';
      dishCount[name] = (dishCount[name] ?? 0) + 1;
    }
    return dishCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(_getPeriodLimit(period)).toList();
  }

  // Calcul du budget par mois
  Map<int, double> _getMonthlyBudget(List<Map<String, dynamic>> dishes) {
    final monthlyBudget = <int, double>{};
    final now = DateTime.now();
    for (var dish in dishes) {
      final createdAt = dish['created_at'] != null
          ? DateTime.parse(dish['created_at'] as String)
          : now; // Fallback à la date actuelle si created_at est absent
      final month = createdAt.month;
      final ingredients = dish['ingredients'] as List<dynamic>;
      double cost = 0.0;
      for (var ingredient in ingredients) {
        cost += (ingredient['price'] as num?)?.toDouble() ?? 0.0;
      }
      monthlyBudget[month] = (monthlyBudget[month] ?? 0.0) + cost;
    }
    return monthlyBudget;
  }

  Map<String, int> _getIngredientUsage(String period, List<Map<String, dynamic>> dishes) {
    final ingredientCount = <String, int>{};
    final filteredDishes = dishes.take(_getPeriodLimit(period)).toList();
    for (var dish in filteredDishes) {
      final ingredients = dish['ingredients'] as List<dynamic>;
      for (var ingredient in ingredients) {
        final name = ingredient['name'] as String? ?? 'Inconnu';
        ingredientCount[name] = (ingredientCount[name] ?? 0) + 1;
      }
    }
    return ingredientCount;
  }

  int _getPeriodLimit(String period) {
    switch (period) {
      case 'Semaine':
        return 4;
      case 'Mois':
        return 12;
      case 'Année':
        return 52;
      default:
        return 0;
    }
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Graphique des plats consommés',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedPeriod,
                      items: ['Semaine', 'Mois', 'Année'].map((period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPeriod = value;
                            _loadData();
                          });
                        }
                      },
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
                        final dishes = snapshot.data!;
                        final consumptionData = _getConsumptionData(_selectedPeriod, dishes);
                        return SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              barGroups: consumptionData.asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.value.toDouble(),
                                      color: tealColor,
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                  showingTooltipIndicators: [0],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < consumptionData.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            consumptionData[index].key.split(' ').first,
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                              maxY: (consumptionData.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1).toDouble(),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suivi budgétaire',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dishesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur lors du chargement du budget');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucun budget disponible');
                        }
                        final dishes = snapshot.data!;
                        final monthlyBudget = _getMonthlyBudget(dishes);
                        final now = DateTime.now();
                        final currentMonth = now.month;
                        return Column(
                          children: [
                            Text('Budget ce mois-ci (Mois $currentMonth) : ${monthlyBudget[currentMonth]?.toStringAsFixed(2) ?? "0.00"}€'),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  barGroups: monthlyBudget.entries.map((entry) {
                                    return BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value,
                                          color: entry.key == currentMonth ? Colors.red : tealColor,
                                          width: 20,
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
                                          return Text(value.toInt().toString());
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                  maxY: (monthlyBudget.values.reduce((a, b) => a > b ? a : b) + 10).toDouble(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                      'Ingrédients les plus utilisés',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _dishesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur lors du chargement des ingrédients');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucun ingrédient disponible');
                        }
                        final dishes = snapshot.data!;
                        final ingredients = _getIngredientUsage(_selectedPeriod, dishes);
                        return SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: ingredients.entries.map((entry) {
                                final index = ingredients.keys.toList().indexOf(entry.key);
                                return PieChartSectionData(
                                  value: entry.value.toDouble(),
                                  title: '${entry.key}\n${entry.value}',
                                  color: _getColor(index),
                                  radius: 80,
                                  titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
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
