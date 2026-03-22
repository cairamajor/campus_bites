import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../db/preferences_helper.dart';

class AIService {
  // Get restaurant suggestions based on mood, time, and remaining budget
  // Filters out any restaurants the user has previously disliked
  static Future<List<Map<String, dynamic>>> getSuggestions({
    required String mood,
    required int minutesBetweenClasses,
  }) async {
    final budget = await PreferencesHelper.getWeeklyBudget();
    final spent = await DatabaseHelper.instance.getWeeklyTotal();
    final remaining = budget - spent;

    final results = await DatabaseHelper.instance.getAISuggestions(
      mood: mood,
      remainingBudget: remaining,
      minutesBetweenClasses: minutesBetweenClasses,
    );

    // Load SharedPreferences once and filter out disliked restaurants
    final prefs = await SharedPreferences.getInstance();
    final filtered = results.where((r) {
      final id = r['id'] as int?;
      if (id == null) return true;
      final feedback = prefs.getBool('feedback_$id');
      // Remove if user thumbed down (false), keep if liked (true) or unrated (null)
      return feedback != false;
    }).toList();

    return filtered;
  }

  // Records user thumbs up/down on a suggestion
  // Saves to SharedPreferences so suggestions improve over time
  static Future<void> recordFeedback({
    required int restaurantId,
    required bool liked,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'feedback_$restaurantId';
    await prefs.setBool(key, liked);
  }

  // Check if a restaurant was previously liked (true), disliked (false), or unrated (null)
  static Future<bool?> getFeedback(int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'feedback_$restaurantId';
    return prefs.getBool(key);
  }

  // Get all restaurant IDs the user has liked — used for pattern-based suggestions
  static Future<List<int>> getLikedRestaurantIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('feedback_'));
    final liked = <int>[];
    for (final key in keys) {
      if (prefs.getBool(key) == true) {
        final id = int.tryParse(key.replaceFirst('feedback_', ''));
        if (id != null) liked.add(id);
      }
    }
    return liked;
  }

  // Message that explains why a suggestion was made
  static String getSuggestionReason({
    required String mood,
    required double remainingBudget,
    required int minutesBetweenClasses,
  }) {
    if (mood == 'Quick Bite' || minutesBetweenClasses < 30) {
      return 'Based on your limited time between classes, we suggest fast and affordable spots!';
    } else if (mood == 'Treat') {
      return 'You deserve a treat! Here are some great options near campus!';
    } else if (mood == 'Late Night') {
      return 'Burning the midnight oil? Here are the best late night spots near campus!';
    } else if (mood == 'Healthy') {
      return 'Eating healthy today! Here are the best healthy spots near campus!';
    } else if (remainingBudget < 8) {
      return 'Budget is running low. Here are the most affordable spots near campus!';
    } else if (remainingBudget < 20) {
      return 'Based on your remaining budget, here are some mid-range options!';
    } else {
      return 'Based on your mood and budget, here are our top picks for you!';
    }
  }

  // List of available moods for the UI chips
  static List<String> getAvailableMoods() {
    return ['Hungry', 'Quick Bite', 'Treat', 'Healthy', 'Late Night'];
  }

  static List<int> getAvailableTimeOptions() {
    return [15, 30, 45, 60, 90];
  }

  static String getTimeLabel(int minutes) {
    if (minutes < 30) {
      return '$minutes mins (Very Short)';
    } else if (minutes < 60) {
      return '$minutes mins (Short)';
    } else {
      return '$minutes mins (Plenty of Time)';
    }
  }
}