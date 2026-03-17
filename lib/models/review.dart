//Review Model

class Review {
  final int? id;
  final int restaurantId;
  final String restaurantName;
  final int rating;
  final String? note;
  final String reviewDate;

  Review ({
    this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.rating,
    required this.note,
    required this.reviewDate,
  });

  //Review map for the database
  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'restaurant_Id': restaurantId,
      'restaurant_name': restaurantName,
      'rating': rating,
      'note': note,
      'review_date': reviewDate,
    };
  }

  //Convert review map for the database
  factory Review.fromMap(Map<String, dynamic> map){
    return Review(
      id: map['id'],
      restaurantId: map['restaurant_id'],
      restaurantName: map['restaurant_name'],
      rating: map['rating'],
      note: map['note'],
      reviewDate: map['review_date'],
    );
  }
}
