import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/main/family_profile_setup_page.dart';
import 'screens/main/home_page.dart';
import 'screens/main/dish_management_page.dart';
import 'screens/main/dish_detail_page.dart';
import 'screens/main/add_dish_page.dart';
import 'screens/main/meal_planning_page.dart';
import 'screens/main/shopping_page.dart';
import 'screens/main/suggestion_page.dart';
import 'screens/main/statistics_page.dart';
import 'screens/main/settings_page.dart';
import 'backend/repositories/auth_repository_impl.dart';
import 'backend/models/user_model.dart';
import 'backend/repositories/family_profile_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepository = AuthRepositoryImpl();
  final familyProfileRepository = FamilyProfileRepositoryImpl();
  await authRepository.init();
  try {
    await familyProfileRepository.isProfileConfigured();
  } catch (e) {
    print('Erreur lors de la vérification du profil : $e');
    // Si la table n'existe pas, on suppose qu'elle doit être créée
    // La prochaine initialisation de la base corrigera cela
  }
  final currentUser = await authRepository.getCurrentUser();
  final isProfileConfigured = await familyProfileRepository
      .isProfileConfigured()
      .catchError((_) => false);
  runApp(
    MenuMaisonApp(
      currentUser: currentUser,
      isProfileConfigured: isProfileConfigured,
    ),
  );
}

class MenuMaisonApp extends StatelessWidget {
  final UserModel? currentUser;
  final bool isProfileConfigured;

  const MenuMaisonApp({
    super.key,
    required this.currentUser,
    required this.isProfileConfigured,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      initialRoute:
          currentUser != null
              ? (isProfileConfigured ? '/home' : '/family-profile-setup')
              : '/',
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
        '/dish-detail':
            (context) => DishDetailPage(
              dish:
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>,
            ),
      },
    );
  }
}

// Page temporaire pour Profil
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
      body: const Center(child: Text('Page Profil (à implémenter)')),
    );
  }
}
