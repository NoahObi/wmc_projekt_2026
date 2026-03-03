class Subscription {
  final int id; 
  final String name;
  final double price;
  final String description;
  final String billingDate; 
  final String categoryName; 
  final String categoryColor; 

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.billingDate,
    required this.categoryName,
    required this.categoryColor,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(), 
      description: json['description'] ?? '', 
      billingDate: json['start_date'], 
      categoryName: json['category_name'] ?? 'Ohne',
      categoryColor: json['color_hex'] ?? '#FFFFFF',
    );
  }
}