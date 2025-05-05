import 'package:flutter/material.dart';
import '../interfaces/stocks.dart'; // Assuming StockItem, StockCategory, StockStatus are here
import '../models/stock_item.dart';

class StockItemEditWidget extends StatefulWidget {
  final StockItem stockItem;
  final Function(StockItem) onSave;
  final VoidCallback onCancel; // Added for potential cancel functionality

  const StockItemEditWidget({
    Key? key,
    required this.stockItem,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  _StockItemEditWidgetState createState() => _StockItemEditWidgetState();
}

class _StockItemEditWidgetState extends State<StockItemEditWidget> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late StockCategory _selectedCategory;
  late StockStatus _selectedStatus;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.stockItem.name);
    _descriptionController =
        TextEditingController(text: widget.stockItem.description);
    _selectedCategory = widget.stockItem.category;
    _selectedStatus = widget.stockItem.status;
    _quantityController =
        TextEditingController(text: widget.stockItem.quantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                DropdownButtonFormField<StockCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: StockCategory.values.map((category) {
                    return DropdownMenuItem<StockCategory>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (category) {
                    if (category != null) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                ),
                DropdownButtonFormField<StockStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: StockStatus.values.map((status) {
                    return DropdownMenuItem<StockStatus>(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    }
                  },
                ),
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,                    
                ),
                if (int.tryParse(_quantityController.text) == null)
                const Text("invalid quantity", style: TextStyle(color: Colors.red)),

                const SizedBox(height: 16),
                // You can add more editable fields here if needed
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      final updatedStockItem = StockItem(
                        id: widget.stockItem.id,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        category: _selectedCategory,
                        status: _selectedStatus,
                        quantity: int.tryParse(_quantityController.text) ??
                            widget.stockItem.quantity,
                      );
                      widget.onSave(updatedStockItem);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}