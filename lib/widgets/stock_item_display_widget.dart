import 'package:flutter/material.dart';
import 'package:elastik_management/interfaces/stocks.dart';
import 'package:elastik_management/models/stock_item.dart';

class StockItemDisplayWidget extends StatelessWidget {
  final StockItem stockItem;
  final VoidCallback onEdit;

  const StockItemDisplayWidget({
    Key? key,
    required this.stockItem,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockItem.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(stockItem.description),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${stockItem.category.name}'),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Text('Status: '),
                        DropdownButton<StockStatus>(
                          value: stockItem.status,
                          items: StockStatus.values.map((StockStatus status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.name),
                            );
                          }).toList(),
                          onChanged: null, // Status is displayed, not edited here
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Text('Quantity: '),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            readOnly: true, // Quantity is displayed, not edited here
                            controller: TextEditingController(text: stockItem.quantity.toString()),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}