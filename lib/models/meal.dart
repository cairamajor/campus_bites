//Meal Model

class Meal {
  final int? id;
  final int restaurantId;
  final String restaurantName;
  final String mealName;
  final double price;
  final String savedDate;

Meal({
  this.id,
  required this.restaurantId,
  required this.restaurantName,
  required this.mealName,
  required this.price,
  required this.savedDate,
  });

  //Meal map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'meal_name': mealName,
      'price': price,
      'saved_date': savedDate,
    };
  }

  //Convert meal map into a meal
  factory Meal.fromMap(Map<String, dynamic>map) {
    return Meal (
      id: map['id'],
      restaurantId: map['restaurant_id'],
      restaurantName: map['restaurant_name'],
      mealName: map['meal_name'],
      price: map['price'],
      savedDate: map['saved_date'],
    );
  }
}