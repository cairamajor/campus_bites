import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  //Returns the database and creating it if it doesn't exist yet
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_bites.db');
    return _database!;
  }
  
  //Initialize database at the correct file path
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  //Create all tables
  Future _createDB(Database db, int version) async {
    //Restaurant Table
    await db.execute('''
      CREATE TABLE restaurants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cuisine TEXT NOT NULL,
        price_range TEXT NOT NULL,
        open_hours TEXT NOT NULL,
        location TEXT NOT NULL,
        menu_highlights TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    //Saved Meals Table
    await db.execute('''
      CREATE TABLE saved_meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurant_id INTEGER NOT NULL,
        restaurant_name TEXT NOT NULL,
        meal_name TEXT NOT NULL,
        price REAL NOT NULL,
        saved_date TEXT NOT NULL,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants (id)
      )
    ''');

    //Review Table
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurant_id INTEGER NOT NULL,
        restaurant_name TEXT NOT NULL,
        rating INTEGER NOT NULL,
        note TEXT,
        review_date TEXT NOT NULL,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants (id)
      )
    ''');
    
    //Budget History Table
    await db.execute('''
      CREATE TABLE budget_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_name TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        date TEXT NOT NULL
      )
    ''');

    //Insert sample data
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    final sampleRestaurants = [
      {
        'name' : 'Stoner\'s Pizza Joint',
        'cuisine' : 'American',
        'price_range' : '\$',
        'open_hours' : '11am - 1am',
        'location' : '120 Piedmont Ave NE',
        'menu_highlights' : 'Large No Brainer Deluxe, Pep-N-Rollie, Garlic Knots ',
        'is_favorite' : 0,
      },
      {
        'name' : 'Mangos Caribbean Restaurant',
        'cuisine' : 'Caribbean',
        'price_range' : '\$\$',
        'open_hours' : '11am - 10pm',
        'location' : '180 Auburn Ave NE',
        'menu_highlights' : 'Jerk Chicken, Curry Chicken, Oxtail',
        'is_favorite': 0,
      },
      {
        'name' : 'Hungry AF',
        'cuisine' : 'American',
        'price_range' : '\$\$',
        'open_hours' : '11am - 12am',
        'location' : '27 Pidemont Ave NE', 
        'menu_highlights' : '6PC Wing W/Fries, King of Gresham, Hungry AF Combo',
        'is_favorite' : 0,
      },
      {
        'name' : 'Moe\'s Southwest Grill',
        'cuisine' : 'Mexican',
        'price_range' : '\$',
        'open_hours' : '10am - 11pm',
        'location' : '171 Auburn Ave NE', 
        'menu_highlights' : 'Moe Value Meal, Chicken Club Quesadilla, Nachos',
        'is_favorite' : 0,
      },
      {
        'name' : 'Sweet Stack Creamery',
        'cuisine' : 'Dessert',
        'price_range' : '\$',
        'open_hours' : '4pm - 11pm',
        'location' : '25 Pidemont Ave NE', 
        'menu_highlights' : 'Ice Cream Cup, Ice Cream Sandwiches, Ice Cream Cone',
        'is_favorite' : 0,
      },
      {
        'name' : 'The Peach Cobbler Factory',
        'cuisine' : 'Dessert',
        'price_range' : '\$',
        'open_hours' : '12pm - 8pm',
        'location' : '171 Auburn Ave NE', 
        'menu_highlights' : 'Peach Cobbler, Classic (OG) Pudding, Caramel Apple Cobbler',
        'is_favorite' : 0,
      },
      {
        'name' : 'Shah\'s Halal',
        'cuisine' : 'Halal',
        'price_range' : '\$',
        'open_hours' : '11am - 12am',
        'location' : '200 Edgewood Ave NE', 
        'menu_highlights' : 'Chicken Over Rice, All Lamb over Rice, Baklava',
        'is_favorite' : 0,
      },
      {
        'name' : 'gusto!',
        'cuisine' : 'Healthy',
        'price_range' :  '\$\$',
        'open_hours' : '10:30am - 8pm',
        'location' : '2 Park Place South NE', 
        'menu_highlights' : 'Fresh Bowls, Wraps, Grilled Proteins',
        'is_favorite' : 0,
      },
      {
        'name': 'India Eats',
        'cuisine': 'Indian',
        'price_range': '\$\$',
        'open_hours': '11am - 10:30pm',
        'location': ' 14 Park Place South SE, Atlanta',
        'menu_highlights': 'Butter Chicken, Goat Biryani, Naan',
        'is_favorite': 0,
      },
      {
        'name': 'Mr. Fries Man',
        'cuisine': 'American',
        'price_range': '\$\$',
        'open_hours': '10am - 5am',
        'location': '30 Decatur St SE, Atlanta',
        'menu_highlights': 'Loaded Fries, Buffalo Ranch Chicken Fries, Honey Garlic Shrimp Fries',
        'is_favorite': 0,
      },
      {
        'name': 'Mr. Hibachi',
        'cuisine': 'Japanese',
        'price_range': '\$',
        'open_hours': '10:30am - 6pm',
        'location': '31 Edgewood Ave SE, Atlanta',
        'menu_highlights': 'Hibachi Chicken, Steak and Shrimp, Teriyaki Chicken',
        'is_favorite': 0,
      },
    ];

    for(final restaurant in sampleRestaurants) {
      await db.insert('restaurants', restaurant);
    }
  }

  //Add a new restaurant (Create)
  Future<int> insertRestaurant(Map<String, dynamic> restaurant) async {
    final db = await instance.database;
    return await db.insert('restaurants', restaurant);
  }

  //Get all restaurants (Read)
  Future<List<Map<String, dynamic>>> getAllRestaurants() async {
    final db = await instance.database;
    return await db.query('restaurants', orderBy: 'name ASC');
  }

  //Filtered by cuisine
  Future<List<Map<String, dynamic>>> getallRestaurants() async {
    final db = await instance.database;
    return await db.query('restaurants', orderBy: 'name ASC');
  }



    }
      
