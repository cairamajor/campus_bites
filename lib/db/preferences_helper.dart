import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _weeklyBudgetKey = 'weekly_budget';
  static const String _favoriteCusineKey = 'favorite_cuisine';
  static const String _priceFilterKey = 'price_filter';
  static const String _notificationsKey = 'notification_enabled';
  static const String _darkModeKey = 'dark_mode';


  //Weekly Budget

  // Save user's weekly budget
  static Future<void> setWeeklyBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_weeklyBudgetKey, amount);
  }

  //Get the user's weekly budget
  static Future<double> getWeeklyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_weeklyBudgetKey) ?? 50.0;
  }

  // Favorite Cuisine Preferences

  //Save user's favorite cuisine
  static Future<void> setFavoriteCuisine(String cuisine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoriteCusineKey, cuisine);
  }

  //Get the user's favorites cuisine
  static Future<String> getFavoriteCuisine() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_favoriteCusineKey) ?? 'All';
  }

  //Price Filter Preference

  //Save the user's price filter preference
  static Future<void> setPriceFilter(String priceFilter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_priceFilterKey, priceFilter);
  }

  //Get the user's price filter 
  static Future<String> getPriceFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_priceFilterKey) ?? 'All';
  }

  //Notification Settings

  //Save notification preference 
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  // Get notification preference 
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  //Dark Mode Setting

  // Save dark mode preference
  static Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  //Get dark mode preference
  static Future<bool> getDarkMode() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey ) ?? false;
  }

  //Reset everything back to defaults
  static Future<void> clearAll() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}