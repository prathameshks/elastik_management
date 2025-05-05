import 'dart:core';

import '../interfaces/stocks.dart';

class StockItem {
  final int id;
  String name;
  String description;
  StockCategory category;
  StockStatus status;
  int quantity;

  StockItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.quantity,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: StockCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => StockCategory.others, // Default category if not found
      ),
      status: StockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockStatus.unavailable, // Default status if not found
      ),
      quantity: json['quantity'] as int,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
    'status': status.name,
    'quantity': quantity,
  };

  // "id": 1,
  // "name": "Drinking Water",
  // "category": "essentials",
  // "status": "available",
  // "description": "Drinking Water",
  // "quantity": 1
}
