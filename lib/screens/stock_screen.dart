import 'package:elastik_management/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elastik_management/widgets/stock_item_display_widget.dart';
import 'package:elastik_management/widgets/stock_item_edit_widget.dart';
import '../interfaces/stocks.dart';
import '../models/stock_item.dart';
import '../utils/data_loader.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'dart:convert';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<StockItem> _stockItems = [];
  List<StockItem> _filteredStockItems = [];
  bool _isAscending = true;
  final Map<int, Widget> _itemWidgets = {};

  // Create controllers for both dropdowns
  final categoryController = MultiSelectController<StockCategory>();
  final statusController = MultiSelectController<StockStatus>();

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  @override
  void dispose() {
    categoryController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> _loadStockData() async {
    String jsonString = await rootBundle.loadString(
      'lib/data/stock_items.json',
    );
    List<dynamic> data = jsonDecode(jsonString);
    _stockItems =
        data
            .map((item) => StockItem.fromJson(item as Map<String, dynamic>))
            .toList();
    _filteredStockItems = List.from(_stockItems);
    _updateItemWidgets();
    setState(() {});
  }

  void _filterItems() {
    setState(() {
      _filteredStockItems =
          _stockItems.where((item) {
            // If no categories selected, don't filter by category
            bool categoryMatch =
                categoryController.selectedItems.isEmpty ||
                categoryController.selectedItems.any(
                  (element) => element.value == item.category,
                );

            // If no statuses selected, don't filter by status
            bool statusMatch =
                statusController.selectedItems.isEmpty ||
                statusController.selectedItems.any(
                  (element) => element.value == item.status,
                );

            return categoryMatch && statusMatch;
          }).toList();

      _updateItemWidgets();
    });
  }

  void _sortItems() {
    setState(() {
      _filteredStockItems.sort(
        (a, b) =>
            _isAscending
                ? a.quantity.compareTo(b.quantity)
                : b.quantity.compareTo(a.quantity),
      );
      _isAscending = !_isAscending;
      _updateItemWidgets();
    });
  }

  void _updateItemWidgets() {
    _itemWidgets.clear();
    for (final item in _filteredStockItems) {
      _itemWidgets[item.id] = StockItemDisplayWidget(
        stockItem: item,
        onEdit: () => _switchToEditWidget(item),
      );
    }
  }

  void _switchToEditWidget(StockItem item) {
    setState(() {
      _itemWidgets[item.id] = StockItemEditWidget(
        stockItem: item,
        onCancel: () {
          _itemWidgets[item.id] = StockItemDisplayWidget(
            stockItem: item,
            onEdit: () => _switchToEditWidget(item),
          );
          setState(() {});
        },
        onSave: (updatedItem) => _updateStockItem(updatedItem),
      );
    });
  }

  void _updateStockItem(StockItem updatedItem) async {
    final index = _stockItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _stockItems[index] = updatedItem;
      _filteredStockItems = List.from(_stockItems);
      _updateItemWidgets();
      setState(() {
        _itemWidgets[updatedItem.id] = StockItemDisplayWidget(
          stockItem: updatedItem,
          onEdit: () => _switchToEditWidget(updatedItem),
        );
      });
      await DataLoader.updateStockItems(_stockItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create dropdown items for categories
    final categoryItems =
        StockCategory.values
            .map(
              (category) => DropdownItem<StockCategory>(
                label: category.name,
                value: category,
              ),
            )
            .toList();

    // Create dropdown items for statuses
    final statusItems =
        StockStatus.values
            .map(
              (status) =>
                  DropdownItem<StockStatus>(label: status.name, value: status),
            )
            .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters header with consistent styling
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                "Filters",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            // Horizontally scrollable filter row
            Container(
              height: 50, // Fixed height to prevent vertical overflow
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Category dropdown - no need for Expanded in scrollable row
                    Container(
                      width:
                          185, // Fixed width that's comfortable for the content
                      child: MultiDropdown<StockCategory>(
                        items: categoryItems,
                        controller: categoryController,
                        enabled: true,
                        fieldDecoration: FieldDecoration(
                          hintText: 'Category',
                          hintStyle: TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onSelectionChange: (selectedItems) => _filterItems(),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Status dropdown - no need for Expanded in scrollable row
                    Container(
                      width:
                          185, // Fixed width that's comfortable for the content
                      child: MultiDropdown<StockStatus>(
                        items: statusItems,
                        controller: statusController,
                        enabled: true,
                        fieldDecoration: FieldDecoration(
                          hintText: 'Status',
                          hintStyle: TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onSelectionChange: (selectedItems) => _filterItems(),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sort button with label - more space now
                    GestureDetector(
                      onTap: _sortItems, // Connect to existing sort method
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Quantity", style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            // Show different icon based on sort direction
                            Icon(
                              _isAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Expanded(child: ListView(children: _itemWidgets.values.toList())),
          ],
        ),
      ),
    );
  }
}
