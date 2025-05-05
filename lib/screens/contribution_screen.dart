import 'package:elastik_management/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/auth_provider.dart';
import '../interfaces/contribution.dart';
import '../models/contribution.dart';
import '../utils/data_loader.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
// import 'dart:convert';

// Placeholder widgets (to be created in subsequent steps)
import '../widgets/contribution_item_display_widget.dart';
import '../widgets/contribution_item_edit_widget.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  List<Contribution> _contributions = [];
  List<Contribution> _filteredContributions = [];
  bool _isAscending = true;
  final Map<int, Widget> _itemWidgets = {};

  final reasonController = MultiSelectController<ContributionReason>();
  final statusController = MultiSelectController<ContributionStatus>();

  @override
  void initState() {
    super.initState();
    _loadContributionData();
  }

  @override
  void dispose() {
    reasonController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> _loadContributionData() async {
    _contributions = await DataLoader.loadContributions();
    _filteredContributions = List.from(_contributions);
    _updateItemWidgets();
    setState(() {});
  }

  void _filterItems() {
    setState(() {
      _filteredContributions =
          _contributions.where((item) {
            bool reasonMatch =
                reasonController.selectedItems.isEmpty ||
                reasonController.selectedItems.any(
                  (element) => element.value == item.reason,
                );

            bool statusMatch =
                statusController.selectedItems.isEmpty ||
                statusController.selectedItems.any(
                  (element) => element.value == item.status,
                );

            return reasonMatch && statusMatch;
          }).toList();

      _updateItemWidgets();
    });
  }

  void _sortItems() {
    setState(() {
      _filteredContributions.sort(
        (a, b) =>
            _isAscending
                ? a.amount.compareTo(b.amount)
                : b.amount.compareTo(a.amount),
      );
      _isAscending = !_isAscending;
      _updateItemWidgets();
    });
  }

  void _updateItemWidgets() {
    _itemWidgets.clear();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.user?.role == 'admin';
    for (final item in _filteredContributions) {
      _itemWidgets[item.id] = ContributionItemDisplayWidget(
        contribution: item,
        onEdit: () => _switchToEditWidget(item),
        isAdmin: isAdmin,
      );
    }
  }

  void _switchToEditWidget(Contribution item) {
    setState(() {
      _itemWidgets[item.id] = ContributionItemEditWidget(
        contribution: item,
        onCancel: () {
          _itemWidgets[item.id] = ContributionItemDisplayWidget(
            isAdmin:
                Provider.of<AuthProvider>(context, listen: false).user?.role ==
                'admin',

            contribution: item,
            onEdit: () => _switchToEditWidget(item),
          );
          setState(() {});
        },
        onSave: (updatedItem) => _updateContributionItem(updatedItem),
      );
    });
  }

  void _updateContributionItem(Contribution updatedItem) async {
    final index = _contributions.indexWhere(
      (item) => item.id == updatedItem.id,
    );
    if (index != -1) {
      _contributions[index] = updatedItem;
      _filteredContributions = List.from(_contributions);
      _updateItemWidgets();
      setState(() {
        _itemWidgets[updatedItem.id] = ContributionItemDisplayWidget(
          isAdmin:
              Provider.of<AuthProvider>(context, listen: false).user?.role ==
              'admin',

          contribution: updatedItem,
          onEdit: () => _switchToEditWidget(updatedItem),
        );
      });
      await DataLoader.updateContributions(_contributions);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    // final isAdmin = authProvider.user?.role == 'admin';
    final reasonItems =
        ContributionReason.values
            .map(
              (reason) => DropdownItem<ContributionReason>(
                label: reason.name,
                value: reason,
              ),
            )
            .toList();

    final statusItems =
        ContributionStatus.values
            .map(
              (status) => DropdownItem<ContributionStatus>(
                label: status.name,
                value: status,
              ),
            )
            .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Container(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 185,
                      child: MultiDropdown<ContributionReason>(
                        items: reasonItems,
                        controller: reasonController,
                        enabled: true,
                        fieldDecoration: FieldDecoration(
                          hintText: 'Reason',
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
                    Container(
                      width: 185,
                      child: MultiDropdown<ContributionStatus>(
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
                    GestureDetector(
                      onTap: _sortItems,
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
                            Text("Amount", style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
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
