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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

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
