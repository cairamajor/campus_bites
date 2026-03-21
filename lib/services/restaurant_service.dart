import '../db/database_helper.dart';
import '../db/preferences_helper.dart';

class RestaurantService {
  // Get all restaurants
  static Future<List<Map<String, dynamic>>> getAllRestaurants() async {
    return await DatabaseHelper.instance.getAllRestaurants();
  }

  // Search restaurants by name or cuisine
  static Future<List<Map<String, dynamic>>> searchRestaurants(
      String query) async {
    if (query.isEmpty) {
      return await getAllRestaurants();
    }
    return await DatabaseHelper.instance.searchRestaurants(query);
  }

  // Filter by both cuisine and price 
  static Future<List<Map<String, dynamic>>> filterByCuisineAndPrice({
    required String cuisine,
    required String priceRange,
  }) async {
    // No filters — return everything
    if (cuisine == 'All' && priceRange == 'All') {
      return await getAllRestaurants();
    }

    final db = await DatabaseHelper.instance.database;

    // Cuisine filter only
    if (cuisine != 'All' && priceRange == 'All') {
      return await db.query(
        'restaurants',
        where: 'cuisine = ?',
        whereArgs: [cuisine],
        orderBy: 'name ASC',
      );
    }

    // Price filter only
    if (cuisine == 'All' && priceRange != 'All') {
      return await db.query(
        'restaurants',
        where: 'price_range = ?',
        whereArgs: [priceRange],
        orderBy: 'name ASC',
      );
    }

    // Both filters
    return await db.query(
      'restaurants',
      where: 'cuisine = ? AND price_range = ?',
      whereArgs: [cuisine, priceRange],
      orderBy: 'name ASC',
    );
  }

  // List of all available cuisines for filter dropdown
  static Future<List<String>> getAvailableCuisines() async {
    final restaurants = await getAllRestaurants();
    final cuisines = restaurants
        .map((r) => r['cuisine'] as String)
        .toSet()
        .toList();
    cuisines.sort();
    cuisines.insert(0, 'All');
    return cuisines;
  }

  // List of all available price ranges for filter dropdown
  static List<String> getAvailablePriceRanges() {
    return ['\$', '\$\$', '\$\$\$'];
  }

  // Get restaurants filtered by user's saved cuisine and price preference
  static Future<List<Map<String, dynamic>>> getRestaurantsByUserPreference() async {
    final cuisine = await PreferencesHelper.getFavoriteCuisine();
    final priceRange = await PreferencesHelper.getPriceFilter();
    return await filterByCuisineAndPrice(
      cuisine: cuisine,
      priceRange: priceRange,
    );
  }
}