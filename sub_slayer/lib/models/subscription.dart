class Subscription {
  final int? id;
  final String name;
  final double price;
  final String description;
  final DateTime startDate;
  final String billingInterval;
  final int? categoryId;
  final String? categoryName;

  Subscription({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.startDate,
    required this.billingInterval,
    this.categoryId,
    this.categoryName,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(raw);
      } catch (_) {
        final parts = raw.split('.');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
        return DateTime.now();
      }
    }

    final idValue = json['id'];
    final id = idValue is int ? idValue : int.tryParse(idValue?.toString() ?? '');

    final name = json['name']?.toString() ?? '';

    return Subscription(
      id: id,
      name: name,
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0,
      description: json['description']?.toString() ?? '',
      startDate: parseDate(json['start_date']?.toString()),
      billingInterval: (json['billing_interval'] as String?) ?? 'monthly',
      categoryId: json['category_id'] is int ? json['category_id'] as int : int.tryParse(json['category_id']?.toString() ?? ''),
      categoryName: json['category_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'billing_interval': billingInterval,
      'category_id': categoryId,
    };
  }
}
