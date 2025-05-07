// lib/services/sync_service.dart
import 'package:menu_maison/backend/database/database_helper.dart';
import 'package:menu_maison/services/nest_service.dart';
import 'dart:async';

class SyncService {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ApiService apiService = ApiService();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  // Initialiser la synchronisation
  void initialize() {
    // Vérifier la connectivité au démarrage
    _checkConnectivity();

    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkConnectivity();
    });
  }

  // Vérifier la connectivité et synchroniser si possible
  Future<void> _checkConnectivity() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none && !_isSyncing) {
      syncData();
    }
  }

  // Synchroniser les données
  Future<void> syncData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      // Synchroniser les utilisateurs
      await _syncUsers();

      // Synchroniser les plats
      await _syncDishes();

      // Synchroniser les profils de famille
      await _syncFamilyProfiles();

      print('Synchronisation terminée');
    } catch (e) {
      print('Erreur de synchronisation: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Synchroniser les utilisateurs
  Future<void> _syncUsers() async {
    // 1. Récupérer les utilisateurs locaux à synchroniser
    final localUsers = await dbHelper.getUnsyncedUsers();

    // 2. Pour chaque utilisateur local
    for (var user in localUsers) {
      try {
        // 3. Envoyer au serveur
        if (user.id == null) {
          // Nouvel utilisateur
          final serverUser = await apiService.createUser(user);
          // Mettre à jour l'ID local avec l'ID du serveur
          await dbHelper.updateUserWithServerId(user.localId!, serverUser.id!);
        } else {
          // Mise à jour d'un utilisateur existant
          await apiService.updateUser(user);
        }

        // 4. Marquer comme synchronisé
        await dbHelper.markUserSynced(user.localId!);
      } catch (e) {
        print('Erreur synchronisation utilisateur: $e');
      }
    }

    // 5. Récupérer les utilisateurs du serveur (si nécessaire)
    // Cette étape est optionnelle selon votre logique d'application
  }

  // Synchroniser les plats
  Future<void> _syncDishes() async {
    // 1. Récupérer les plats locaux à synchroniser
    final localDishes = await dbHelper.getUnsyncedDishes();

    // 2. Pour chaque plat local
    for (var dish in localDishes) {
      try {
        // 3. Envoyer au serveur
        if (dish.id == null) {
          // Nouveau plat
          final serverDish = await apiService.createDish(dish);
          await dbHelper.updateDishWithServerId(dish.localId!, serverDish.id!);
        } else {
          // Mise à jour d'un plat existant
          await apiService.updateDish(dish);
        }

        // 4. Marquer comme synchronisé
        await dbHelper.markDishSynced(dish.localId!);
      } catch (e) {
        print('Erreur synchronisation plat: $e');
      }
    }

    // 5. Récupérer les nouveaux plats du serveur
    try {
      final serverDishes = await apiService.getAllDishes();
      final localDishIds = await dbHelper.getAllDishIds();

      // Ajouter les plats qui n'existent pas localement
      for (var dish in serverDishes) {
        if (!localDishIds.contains(dish.id)) {
          await dbHelper.insertDish(dish, synced: true);
        }
      }
    } catch (e) {
      print('Erreur récupération plats serveur: $e');
    }
  }

  // Synchroniser les profils de famille
  Future<void> _syncFamilyProfiles() async {
    // Implémentation similaire aux autres méthodes
    final localProfiles = await dbHelper.getUnsyncedFamilyProfiles();

    for (var profile in localProfiles) {
      try {
        if (profile.id == null) {
          final serverProfile = await apiService.createFamilyProfile(profile);
          await dbHelper.updateFamilyProfileWithServerId(
            profile.localId!,
            serverProfile.id!,
          );
        } else {
          // Supposons que vous avez une méthode updateFamilyProfile dans ApiService
          await apiService.updateFamilyProfile(profile);
        }

        await dbHelper.markFamilyProfileSynced(profile.localId!);
      } catch (e) {
        print('Erreur synchronisation profil famille: $e');
      }
    }
  }

  // Nettoyer les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
