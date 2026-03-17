import '../db/database_helper.dart';
import '../db/preferences_helper.dart';

class BudgetService {
  static Future<double> getWeeklyBudget() async {
    return await PreferencesHelper.getWeeklyBudget();
  }

  //Get total amount spent this week from SQLite
  static Future<double> getWeeklySpending() async {
    return await DatabaseHelper.instance.getWeeklyTotal();
  }

  //Calculate remaining budget for the week
  static Future<double> getRemainingBudget() async {
    final budget = await getWeeklyBudget();
    final spent = await getWeeklySpending();
    final remaining = budget - spent;

    return remaining < 0 ? 0 : remaining;
  }

  //Check if user is over budget
  static Future<bool> isOverBudget() async {
    final budget = await getRemainingBudget();
    final spent = await getWeeklySpending();
    return spent > budget;
  }

  //Check if user is near to budget
  static Future<bool> isNearBudget() async{
    final budget = await getWeeklyBudget();
    final spent = await getWeeklySpending();
    final remaining = budget - spent;
    return remaining <= 5 && remaining > 0;
  }

  //Get budget status message to show user
  static Future<String> getBudgetStatusMessage() async {
    final budget = await getWeeklyBudget();
    final spent = await getWeeklySpending();
    final remaining = budget - spent;

    if (spent > budget) {
      return 'You are \$${(spent - budget). toStringAsFixed(2)} over your weekly budget!';  
    } else if (remaining <= 5){
      return 'Almost out of budget! Only \$${remaining.toStringAsFixed(2)} left.';
    } else {
      return 'You have \$${remaining.toStringAsFixed(2)} left this week.';
    }
  }

  //Add a meal expense to budget history
  static Future<void> logMealExpense({
    required String mealName,
    required double amount, 
    String ? category,
  }) async {
    final entry = {
      'meal_name' : mealName,
      'amount' : amount,
      'category' : category ?? 'General',
      'date': DateTime.now().toIso8601String().substring(0, 10),
    };
    await DatabaseHelper.instance.insertBudgetEntry(entry);
  }

  // Get all expenses for the current week
  static Future<List<Map<String, dynamic>>> getWeeklyExpenses() async {
    return await DatabaseHelper.instance.getWeeklyBudgetEntries();
  }

  // Get all expenses ever
  static Future<List<Map<String, dynamic>>> getAllExpenses() async {
    return await DatabaseHelper.instance.getAllBudgetEntries();
  }

  // Delete an expense
  static Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteBudgetEntry(id);
  }


  // Update the weekly budget setting
  static Future<void> updateWeeklyBudget(double newBudget) async {
    await PreferencesHelper.setWeeklyBudget(newBudget);
  }

  
  // Get budget percentage used 
  static Future<double> getBudgetPercentageUsed() async {
    final budget = await getWeeklyBudget();
    final spent = await getWeeklySpending();
    if (budget == 0) return 0;
    final percentage = spent / budget;
    
    return percentage > 1.0 ? 1.0 : percentage;
  }
}