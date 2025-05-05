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
  final ValueNotifier<List<StockCategory>> _selectedCategories = ValueNotifier<List<StockCategory>>([]);
  final ValueNotifier<List<StockStatus>> _selectedStatuses = ValueNotifier<List<StockStatus>>([]);
  final Map<int, Widget> _itemWidgets = {};

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    String jsonString = await rootBundle.loadString('lib/data/stock_items.json');
    List<dynamic> data = jsonDecode(jsonString);
    _stockItems = data.map((item) => StockItem.fromJson(item as Map<String, dynamic>)).toList();
    _filteredStockItems = List.from(_stockItems);    
    _updateItemWidgets();
    setState(() {});
  }

  void _filterItems() {
    _filteredStockItems = _stockItems.where((item) {
      return _selectedCategories.value.contains(item.category) &&
          _selectedStatuses.value.contains(item.status); 
    }).toList();
    _updateItemWidgets();
    setState(() {});
  }

  void _sortItems() {
    _filteredStockItems.sort((a, b) => _isAscending ? a.quantity.compareTo(b.quantity) : b.quantity.compareTo(a.quantity));
    _isAscending = !_isAscending;
    _updateItemWidgets();
    setState(() {});
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
        onCancel: (){
           _itemWidgets[item.id] = StockItemDisplayWidget(stockItem: item,onEdit: () => _switchToEditWidget(item));
           setState(() { });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Management')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<List<StockCategory>>(
                    valueListenable: _selectedCategories,
                    builder: (context, value, child) => MultiDropDown(
                      onOptionSelected: (List<ValueItem> selected) {
                       _selectedCategories.value = selected.map((e) => StockCategory.values.byName(e.value)).toList();
                        _filterItems();
                      },
                      options: StockCategory.values.map((e) => ValueItem(label: e.name, value: e.name)).toList(),
                      selectionType: SelectionType.multi,
                    ),
                  ),
                ), Expanded(
                  child: ValueListenableBuilder<List<StockStatus>>(
                      valueListenable: _selectedStatuses,
                      builder: (context, value, child) => MultiSelectDropDown(
                        onOptionSelected: (List<DropdownItem> selected) {
                          _selectedStatuses.value = selected.map((e) => StockStatus.values.byName(e.value)).toList();
                          _filterItems();
                        },
                        options: StockStatus.values.map((e) => ValueItem(label: e.name, value: e.name)).toList(),
                        selectionType: SelectionType.multi,
                      )),
                ),
                IconButton(onPressed: _sortItems, icon: const Icon(Icons.sort)),
              ],
            ),
            Expanded(child: ListView(children: _itemWidgets.values.toList())),
          ],
        ),
      ),
    );
  }
}