import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/main/family_profile_setup_page.dart';
import 'screens/main/home_page.dart';
import 'screens/main/dish_management_page.dart';
import 'screens/main/add_dish_page.dart';
import 'screens/main/meal_planning_page.dart';
import 'screens/main/shopping_page.dart';
import 'screens/main/suggestion_page.dart';
import 'screens/main/statistics_page.dart';

void main() {
  runApp(const MenuMaisonApp());
}

class MenuMaisonApp extends StatelessWidget {
  const MenuMaisonApp({super.key});

  // Simule l'état de configuration (à remplacer par une vérification réelle)
  bool isProfileConfigured() => false; // Change à true après configuration

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      initialRoute: isProfileConfigured() ? '/home' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/family-profile-setup': (context) => const FamilyProfileSetupPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/dishes': (context) => const DishManagementPage(),
        '/add-dish': (context) => const AddDishPage(),
        '/planning': (context) => const MealPlanningPage(),
        '/shopping': (context) => const ShoppingPage(),
        '/suggestions': (context) => const SuggestionPage(),
        '/statistics': (context) => const StatisticsPage(),
      },
    );
  }
}

// Page temporaire pour Profil
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
      ),
      body: const Center(
        child: Text('Page Profil (à implémenter)'),
      ),
    );
  }
}

// Page temporaire pour Paramètres
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
      ),
      body: const Center(
        child: Text('Page Paramètres (à implémenter)'),
      ),
    );
  }
}
