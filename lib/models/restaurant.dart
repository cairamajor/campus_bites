//Restaurant model
class Restaurant {
  final int? id;
  final String name;
  final String cuisine;
  final String priceRange;
  final String openHours;
  final String location;
  final String? menuHighlights;
  final int isFavorite;

  Restaurant({
    this.id,
    required this.name,
    required this.cuisine,
    required this.priceRange,
    required this.openHours,
    required this.location,
    this.menuHighlights,
    this.isFavorite = 0,
  });

  // Restaurant map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'price_range': priceRange,
      'open_hours': openHours,
      'location': location,
      'menu_highlights': menuHighlights,
      'is_favorite': isFavorite,
    };
  }

  //Convert restaurant map into a restaurant
  factory Restaurant.fromMap(Map<String, dynamic>map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      cuisine: map['cuisine'],
      priceRange: map['price_range'],
      openHours: map['open_hours'],
      location: map['location'],
      menuHighlights: map['menu_highlights'],
      isFavorite: map['is_favorite'],
    );
  }
}
