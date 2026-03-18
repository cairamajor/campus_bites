import '../db/database_helper.dart';


class FavoritesService {
  // Get all favorite restaurants
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    return await DatabaseHelper.instance.getFavoriteRestaurants();
  }

  // Add a restaurant to favorites
  static Future<void> addToFavorites(int restaurantId) async {
    await DatabaseHelper.instance.toggleFavorite(restaurantId, 1);
  }

  // Remove a restaurant from favorites
  static Future<void> removeFromFavorites(int restaurantId) async {
    await DatabaseHelper.instance.toggleFavorite(restaurantId, 0);
  }

  // Check if a restaurant is already favorited
  static Future<bool> isFavorite(int restaurantId) async {
    final favorites = await getFavorites();
    return favorites.any((r) => r['id'] == restaurantId);
  }

  // Toggle favorite
  static Future<bool> toggleFavorite(int restaurantId) async {
    final alreadyFavorited = await isFavorite(restaurantId);
    if (alreadyFavorited) {
      await removeFromFavorites(restaurantId);
      return false; 
    } else {
      await addToFavorites(restaurantId);
      return true; 
    }
  }

  // Save a meal from a restaurant
  static Future<void> saveMeal({
    required int restaurantId,
    required String restaurantName,
    required String mealName,
    required double price,
  }) async {
    final meal = {
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'meal_name': mealName,
      'price': price,
      'saved_date': DateTime.now().toIso8601String().substring(0, 10),
    };
    await DatabaseHelper.instance.insertSavedMeal(meal);
  }

  // Get all saved meals
  static Future<List<Map<String, dynamic>>> getSavedMeals() async {
    return await DatabaseHelper.instance.getAllSavedMeals();
  }

  // Remove a saved meal
  static Future<void> removeSavedMeal(int id) async {
    await DatabaseHelper.instance.deleteSavedMeal(id);
  }
}
