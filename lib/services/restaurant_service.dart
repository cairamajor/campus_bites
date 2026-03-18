import '../db/database_helper.dart';
import '../db/preferences_helper.dart';


class RestaurantService {
  static Future<List<Map<String, dynamic>>> getAllRestaurants() async{
    return await DatabaseHelper.instance.getAllRestaurants();
  }
// Search restaurants by name or cuisine
  static Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    if (query.isEmpty) {
      return await getAllRestaurants();
    }
    return await DatabaseHelper.instance.searchRestaurants(query);
  }
// Filter restaurants by cuisine
  static Future<List<Map<String, dynamic>>> filterByCuisine(String cuisine) async {
    if (cuisine == 'All') {
      return await getAllRestaurants();
    }
    return await DatabaseHelper.instance.getRestaurantsByCuisine(cuisine);
  }

//Filter restaurants by price range
static Future<List<Map<String, dynamic>>> filterByPrice(String priceRange) async {
  if (priceRange == 'All') {
    return await getAllRestaurants();
  }
  return await DatabaseHelper.instance.getRestaurantsByPrice(priceRange);
}
//Filter by both cuisine and price
static Future<List<Map<String, dynamic>>> filterByCuisineAndPrice({
  required String cuisine,
  required String priceRange,
}) async {
  if (cuisine == 'All' && priceRange == 'All') {
    return await getAllRestaurants();
  }
  if (cuisine != 'All' && priceRange == 'All') {
    return await filterByCuisine(cuisine);
  }
  if (cuisine == 'All' && priceRange!= 'All') {
    return await filterByPrice(priceRange);
  }
  final db = await DatabaseHelper.instance.database;
  return await db.query(
    'restaurants',
    where: 'cuisine = ? AND price_range = ?',
    whereArgs: [cuisine, priceRange],
    orderBy: 'name ASC',
  );
}
//List of all available cuisines for filter dropdown
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

// Get users saved cuisine preference and filter by it
static Future<List<Map<String, dynamic>>> getRestaurantsByUserPreference() async {
    final cuisine = await PreferencesHelper.getFavoriteCuisine();
    final priceRange = await PreferencesHelper.getPriceFilter();
    return await filterByCuisineAndPrice(
      cuisine: cuisine,
      priceRange: priceRange,
    );
  }
}