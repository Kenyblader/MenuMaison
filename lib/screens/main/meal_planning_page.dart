import 'package:flutter/material.dart';
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

  // Simule les repas planifiés (à remplacer par une base de données plus tard)
  final Map<DateTime, Map<String, String>> _meals = {
    DateTime(2025, 5, 6): {
      'Petit-déjeuner': 'Croissants',
      'Déjeuner': 'Salade César',
      'Dîner': 'Pizza',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planification des repas'),
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
                      _selectedDay = selectedDay;
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
              child: _selectedDay == null
                  ? const Center(child: Text('Sélectionnez un jour'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repas du ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildMealCard('Petit-déjeuner', _meals[_selectedDay]?['Petit-déjeuner']),
                        _buildMealCard('Déjeuner', _meals[_selectedDay]?['Déjeuner']),
                        _buildMealCard('Dîner', _meals[_selectedDay]?['Dîner']),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
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
                          child: const Text('Suggérer un menu équilibré', style: TextStyle(fontSize: 16)),
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
              builder: (context) => AlertDialog(
                title: Text('Modifier $mealType'),
                content: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Sélectionnez un plat'),
                  items: const [
                    DropdownMenuItem(value: 'Croissants', child: Text('Croissants')),
                    DropdownMenuItem(value: 'Salade César', child: Text('Salade César')),
                    DropdownMenuItem(value: 'Pizza', child: Text('Pizza')),
                    DropdownMenuItem(value: 'Pancakes', child: Text('Pancakes')),
                    DropdownMenuItem(value: 'Salade Niçoise', child: Text('Salade Niçoise')),
                    DropdownMenuItem(value: 'Pâtes Carbonara', child: Text('Pâtes Carbonara')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (_meals[_selectedDay!] == null) {
                        _meals[_selectedDay!] = {};
                      }
                      _meals[_selectedDay!]![mealType] = value!;
                    });
                    Navigator.pop(context);
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
