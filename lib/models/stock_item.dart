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

  // "id": 1,
  // "name": "Drinking Water",
  // "category": "essentials",
  // "status": "available",
  // "description": "Drinking Water",
  // "quantity": 1
}
