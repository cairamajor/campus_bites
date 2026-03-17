//BudgetEntry model

class BudgetEntry {
  final int? id;
  final String mealName;
  final double amount;
  final String? category;
  final String date;

  BudgetEntry({
    this.id,
    required this.mealName,
    required this.amount,
    required this.category,
    required this.date,
  });

  //Budget map for the database
  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'meal_name': mealName,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  //Convert BudgetEntry Map for the database
  factory BudgetEntry.fromMap(Map<String, dynamic> map) {
    return BudgetEntry(
      id: map['id'],
      mealName: map['meal_name'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
    );
  }
}
