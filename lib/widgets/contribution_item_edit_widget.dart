import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elastik_management/interfaces/contribution.dart';
import 'package:elastik_management/models/contribution.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:elastik_management/utils/auth_provider.dart';


class ContributionItemEditWidget extends StatefulWidget {
  final Contribution contribution;
  final VoidCallback onCancel;
  final Function(Contribution) onSave;

  const ContributionItemEditWidget({
    super.key,
    required this.contribution,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<ContributionItemEditWidget> createState() =>
      _ContributionItemEditWidgetState();
}

class _ContributionItemEditWidgetState
    extends State<ContributionItemEditWidget> {
  late Contribution _editedContribution;
  bool _isAdmin = false; // Initialize to false
  final TextEditingController _amountController = TextEditingController();
  final reasonController = MultiSelectController<ContributionReason>();
  final statusController = MultiSelectController<ContributionStatus>();

  @override
  void initState() {
    super.initState();
    _editedContribution = Contribution(
      id: widget.contribution.id,
      reason: widget.contribution.reason,
      amount: widget.contribution.amount,
      user: widget.contribution.user,
      status: ContributionStatus.unpaid,
    );
    _editedContribution.status = widget.contribution.status; // Copy status
    _amountController.text = _editedContribution.amount.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminRole(context);
    });
  }

  Future<void> _checkAdminRole(BuildContext context) async {
    _isAdmin = await AuthProvider().isAdmin();
    setState(() {}); // Update the UI based on admin status
  }

  @override
  void dispose() {
    _amountController.dispose();
    reasonController.dispose();
    statusController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_isAdmin) return; // Prevent saving if not admin

    try {
      _editedContribution.amount = double.parse(_amountController.text);
      _editedContribution.reason = reasonController.selectedItems.first.value;
      _editedContribution.status = statusController.selectedItems.first.value;
      widget.onSave(_editedContribution);
    } catch (e) {
      // Handle potential parsing errors
      print('Error saving contribution: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    _isAdmin = user?.role == "admin";
    reasonController.setItems([
      DropdownItem(
        label: _editedContribution.reason.name,
        value: _editedContribution.reason,
      ),
    ]);
    statusController.setItems([
      DropdownItem(
        label: _editedContribution.status.name,
        value: _editedContribution.status,
      ),
    ]);
    // Create dropdown items for reasons
    final reasonItems =
        ContributionReason.values
            .map(
              (reason) => DropdownItem<ContributionReason>(
                label: reason.name,
                value: reason,
              ),
            )
            .toList();

    // Create dropdown items for statuses
    final statusItems =
        ContributionStatus.values
            .map(
              (status) => DropdownItem<ContributionStatus>(
                label: status.name,
                value: status,
              ),
            )
            .toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editing: ${widget.contribution.user.name}'),
            const SizedBox(height: 8.0),
            MultiDropdown<ContributionReason>(
              items: reasonItems,
              controller: reasonController,
              enabled: _isAdmin && user != null, // Only enabled for admin
              fieldDecoration: FieldDecoration(
                hintText: 'Reason',
                hintStyle: TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            MultiDropdown<ContributionStatus>(
              items: statusItems,
              controller: statusController,
              enabled: _isAdmin && user != null, // Only enabled for admin
              fieldDecoration: FieldDecoration(
                hintText: 'Status',
                hintStyle: TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                enabled: _isAdmin && user != null, // Only enabled for admin
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed:
                      _isAdmin && user != null
                          ? _saveChanges
                          : null, // Disable if not admin
                  child: const Text('Save'),
                ),
              ],
            ),
            if (!_isAdmin) // Show a message if not admin
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Only administrators can edit contributions.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
