import '../db/database_helper.dart';
import '../db/preferences_helper.dart';

class AIService {
  static Future<List<Map<String, dynamic>>> getSuggestions({
    required String mood,
    required int minutesBetweenClasses,
  }) async {

    final budget = await PreferencesHelper.getWeeklyBudget();
    final spent = await DatabaseHelper.instance.getWeeklyTotal();
    final remaining = budget - spent;

    return await DatabaseHelper.instance.getAISuggestions(
      mood: mood,
      remainingBudget: remaining,
      minutesBetweenClasses: minutesBetweenClasses,
      );
  }

  //Message that explains why a restaurant was suggested 
  static String getSuggestionReason({
    required String mood,
    required double remainingBudget,
    required int minutesBetweenClasses,
  }) {
    if (mood == 'Quick Bite' || minutesBetweenClasses < 30) {
      return 'Based on your limited time between classes, we suggest fast and affordable spots!';   
    } else if (mood == 'Treat'){
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

  //List of available moods for the UI dropdown
  static List<String> getAvailableMoods(){
    return [
      'Hungry',
      'Quick Bite',
      'Treat',
      'Healthy',
      'Late Night',
    ];
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