import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';

class ReviewService {
  static Future<void> addReview ({
    required int restaurantId,
    required String restaurantName,
    required int rating,
    String ? note,
  }) async {
    final review = {
      'restaurant_id' : restaurantId,
      'restaurant_name' : restaurantName,
      'rating' : rating,
      'note' : note ?? '',
      'review_date' : DateTime.now().toIso8601String().substring(0, 10),    
    };
    await DatabaseHelper.instance.insertReview(review);
  }

  //Get all reviews for a specific restaurant
  static Future<List<Map<String, dynamic>>> getReviewsForRestaurant(
    int restaurantId) async {
      return await DatabaseHelper.instance
      .getReviewsForRestaurant(restaurantId);
    }

    //Get all reviews
    static Future<List<Map<String, dynamic>>> getAllReviews() async {
      return await DatabaseHelper.instance.getAllReviews();
    }

    //Delete a review
    static Future<void> deleteReview(int id) async {
      await DatabaseHelper.instance.deleteReview(id);
    }
    
    //Calculating avg rating for a restaurant 
    static Future<double> getAverageRating(int restaurantId) async {
      final reviews = await getReviewsForRestaurant(restaurantId);
      if (reviews.isEmpty) return 0.0;

      double total = 0.0;
      for (final review in reviews) {
        total+= review['rating'] as int;
      }
      return total/ reviews.length;
    }

    //Star rating label
    static String getRatinglabel(int rating) {
      switch(rating) {
        case 1:
        return 'Poor';
        case 2:
        return 'Fair';
        case 3: 
        return 'Good';
        case 4:
        return 'Great';
        case 5: 
        return 'Excellent';
        default:
        return 'No rating';
      }
    }

    //Check if user already reviewed a restaurant
    static Future<bool> hasReviewed(int restaurantId) async {
      final reviews = await getReviewsForRestaurant(restaurantId);
      return reviews.isNotEmpty;
    }
}