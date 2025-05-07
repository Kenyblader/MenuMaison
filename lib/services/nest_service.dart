// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menu_maison/backend/entities/family_profile_entity.dart';
import 'package:menu_maison/backend/entities/user_entity.dart';
import 'package:menu_maison/backend/models/dish.dart';

const String server = "172.29.141.193";

class ApiService {
  final String baseUrl = 'http://$server:3000'; // Remplacez par votre URL
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  // Authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Stocker le token pour les futures requêtes
      headers['Authorization'] = 'Bearer ${data['token']}';
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  // Utilisateurs
  Future<UserEntity> createUser(UserEntity user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: headers,
      body: jsonEncode(user.toMap()),
    );

    if (response.statusCode == 201) {
      return UserEntity.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  Future<UserEntity> getUser(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return UserEntity.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<UserEntity> updateUser(UserEntity user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: headers,
      body: jsonEncode(user.toMap()),
    );

    if (response.statusCode == 200) {
      return UserEntity.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  // Plats
  Future<List<Dish>> getAllDishes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dishes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Dish.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load dishes');
    }
  }

  Future<Dish> createDish(Dish dish) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dishes'),
      headers: headers,
      body: jsonEncode(dish.toMap()),
    );

    if (response.statusCode == 201) {
      return Dish.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create dish');
    }
  }

  Future<Dish> updateDish(Dish dish) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dishes/${dish.id}'),
      headers: headers,
      body: jsonEncode(dish.toMap()),
    );

    if (response.statusCode == 200) {
      return Dish.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update dish');
    }
  }

  // Profils de famille
  Future<FamilyProfileEntity> createFamilyProfile(
    FamilyProfileEntity profile,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/family-profiles'),
      headers: headers,
      body: jsonEncode(profile.toMap()),
    );

    if (response.statusCode == 201) {
      return FamilyProfileEntity.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create family profile');
    }
  }

  // Autres méthodes pour les sessions, etc.
}
