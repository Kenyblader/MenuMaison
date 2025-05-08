import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:menu_maison/backend/repositories/dish_repository_impl.dart';
import 'package:menu_maison/backend/repositories/meal_plan_repository_impl.dart';
import 'package:menu_maison/utils/auth_state.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:menu_maison/utils/theme.dart';

class MealPlanningPage extends StatefulWidget {
  const MealPlanningPage({super.key});

  @override
  State<MealPlanningPage> createState() => _MealPlanningPageState();
}

class _MealPlanningPageState extends State<MealPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final _mealRepository = MealPlanRepositoryImpl();
  final _dishRepositoty = DishRepositoryImpl();

  // Simule les repas planifiés (à remplacer par une base de données plus tard)
  final Map<DateTime, Map<String, String>> _meals = {};
  final dishes = [];

  @override
  void initState() {
    _loadMealPlannings();
    _loadDishes();
    super.initState();
  }

  _loadMealPlannings() async {
    final data = await _mealRepository.getMealPlan();
    final Map<DateTime, Map<String, String>> result = {};
    print("data ${data.length}");
    for (var plan in data) {
      final dateOnly = DateTime(plan.date.year, plan.date.month, plan.date.day);

      if (!result.containsKey(dateOnly)) {
        result[dateOnly] = {};
      }
      String name = await DishRepositoryImpl().getDisheById(plan.dishId).then((
        dish,
      ) {
        return dish['name'];
      });
      result[dateOnly]![plan.mealType] =
          name; // Assure-toi que dishName est bien dispo
    }
    _meals.clear();
    _meals.addAll(result);
    print("meals: ${_meals.toString()}");
  }

  _loadDishes() async {
    final dishs = await _dishRepositoty.getDishes();
    dishes.clear();
    dishes.addAll(dishs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planification des repas'),
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
        child: Column(
          children: [
            // Calendrier
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: tealColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: tealColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                  ),
                ),
              ),
            ),
            // Repas du jour sélectionné
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  _selectedDay == null
                      ? const Center(child: Text('Sélectionnez un jour'))
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repas du ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildMealCard(
                            'Petit-déjeuner',
                            _meals[_selectedDay]?['Petit-déjeuner'],
                          ),
                          _buildMealCard(
                            'Déjeuner',
                            _meals[_selectedDay]?['Déjeuner'],
                          ),
                          _buildMealCard(
                            'Dîner',
                            _meals[_selectedDay]?['Dîner'],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              print("selecedDay: ${_selectedDay}");
                              // Simule une suggestion de repas équilibré
                              setState(() {
                                _meals[_selectedDay!] = {
                                  'Petit-déjeuner': 'Pancakes',
                                  'Déjeuner': 'Salade Niçoise',
                                  'Dîner': 'Pâtes Carbonara',
                                };
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tealColor,
                              foregroundColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Suggérer un menu équilibré',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealType, String? dish) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        title: Text(mealType),
        subtitle: Text(dish ?? 'Aucun plat sélectionné'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: tealColor),
          onPressed: () {
            // Simule la modification d'un repas
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Modifier $mealType'),
                    content: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Sélectionnez un plat'),
                      items:
                          dishes
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e['id'].toString(),
                                  child: Text(e['name']),
                                ),
                              )
                              .toList(),
                      onChanged: (value) async {
                        try {
                          await _mealRepository.saveMealPlan({
                            'user_id': AuthState.userId,
                            'date': _selectedDay?.toIso8601String(),
                            'meal_type': mealType,
                            'dish_id': value,
                          });
                          setState(() {
                            if (_meals[_selectedDay!] == null) {
                              _meals[_selectedDay!] = {};
                            }
                            _meals[_selectedDay!]![mealType] =
                                dishes.singleWhere(
                                  (e) => e['id'].toString() == value,
                                )['name'];
                          });
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("desole une erreur c'es produite"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
            );
          },
        ),
      ),
    );
  }
}
