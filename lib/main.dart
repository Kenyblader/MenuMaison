import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:menu_maison/screens/main/map_page.dart';
import 'package:menu_maison/screens/main/profile_page.dart';
import 'package:menu_maison/screens/main/vocal_list.dart';
import 'package:menu_maison/services/gemini_service.dart';
import 'package:menu_maison/services/sync_service.dart';
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
  await runAppAfterDbInit();
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('mapStore').manage.create();
}

Future<void> runAppAfterDbInit() async {
  try {
    Geminservice.init();
    final authRepository = AuthRepositoryImpl();
    final familyProfileRepository = FamilyProfileRepositoryImpl();

    await authRepository.init(); // s'assure que la DB est bien prête
    SyncService().initialize();

    bool isProfileConfigured = false;
    try {
      isProfileConfigured = await familyProfileRepository.isProfileConfigured();
    } catch (e) {
      print('Erreur lors de la vérification du profil : $e');
    }

    UserModel? currentUser;
    try {
      currentUser = await authRepository.getCurrentUser();
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    }

    runApp(
      MenuMaisonApp(
        currentUser: currentUser,
        isProfileConfigured: isProfileConfigured,
      ),
    );
  } catch (e, stack) {
    print("Erreur critique lors de l'initialisation : $e");
    print(stack);
    runApp(const MaterialApp(home: ErrorScreen()));
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Erreur lors de l’initialisation de l’application.'),
      ),
    );
  }
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
      debugShowCheckedModeBanner: false,
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
        '/vocalList': (context) => const Audiolistform(),
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
