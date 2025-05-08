import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'menu_maison.db');
    
    print("ouverture de la base de donne");
    return await openDatabase(
      path,
      version:
          5, // Incrémenter la version pour gérer la nouvelle structure des ingrédients
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            name TEXT,
            synced INTEGER DEFAULT 0,
            lastUpdated INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE family_profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            totalMembers INTEGER NOT NULL,
            adults INTEGER NOT NULL,
            children INTEGER NOT NULL,
            babies INTEGER NOT NULL,
            dietaryRestrictions TEXT,
            region TEXT,
            synced INTEGER DEFAULT 0,
            lastUpdated INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE dishes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            prepTime INTEGER NOT NULL,
            cookTime INTEGER NOT NULL,
            servings INTEGER NOT NULL,
            tutorialLink TEXT,
            ingredients TEXT, -- Liste d'ingrédients au format JSON : [{'name': String, 'price': double}]
            photoPath TEXT,
            synced INTEGER DEFAULT 0,
            lastUpdated INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE meal_plans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date DATE NOT NULL, -- Date du repas
    meal_type TEXT NOT NULL, -- Type de repas (ex. "petit-déjeuner", "déjeuner", "dîner")
    dish_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dishes(id) ON DELETE CASCADE
    );
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE family_profiles (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              totalMembers INTEGER NOT NULL,
              adults INTEGER NOT NULL,
              children INTEGER NOT NULL,
              babies INTEGER NOT NULL,
              dietaryRestrictions TEXT,
              region TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE dishes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              description TEXT,
              prepTime INTEGER NOT NULL,
              cookTime INTEGER NOT NULL,
              servings INTEGER NOT NULL,
              tutorialLink TEXT,
              ingredients TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE dishes ADD COLUMN photoPath TEXT');
        }
        if (oldVersion < 5) {
          // Migration pour la version 5 : ajuster la structure des ingrédients
          final dishes = await db.query('dishes');
          for (var dish in dishes) {
            final dishData = Map<String, dynamic>.from(dish);
            final ingredientsJson = dishData['ingredients'] as String?;
            if (ingredientsJson != null && ingredientsJson.isNotEmpty) {
              final ingredients = List<Map<String, dynamic>>.from(
                jsonDecode(ingredientsJson),
              );
              // Transformer les anciens ingrédients ({name, quantity, unit}) en nouveaux ({name, price})
              final updatedIngredients =
                  ingredients.map((ingredient) {
                    return {
                      'name': ingredient['name'],
                      'price':
                          0.0, // Prix par défaut, car l'ancienne structure n'avait pas de prix
                    };
                  }).toList();
              dishData['ingredients'] = jsonEncode(updatedIngredients);
              await db.update(
                'dishes',
                dishData,
                where: 'id = ?',
                whereArgs: [dishData['id']],
              );
            }
          }
        }
      },
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
