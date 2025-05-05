import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elastik_management/interfaces/contribution.dart';
import 'package:elastik_management/models/contribution.dart';
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
  bool _isAdmin = false;
  final TextEditingController _amountController = TextEditingController();
  late ContributionReason _selectedReason;
  late ContributionStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _editedContribution = Contribution(
      id: widget.contribution.id,
      reason: widget.contribution.reason,
      amount: widget.contribution.amount,
      user: widget.contribution.user,
      status: widget.contribution.status,
    );
    _amountController.text = _editedContribution.amount.toString();

    // Initialize selected values from the contribution
    _selectedReason = _editedContribution.reason;
    _selectedStatus = _editedContribution.status;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    _isAdmin = user?.role == "admin";
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_isAdmin) return;

    try {
      _editedContribution.amount = double.parse(_amountController.text);
      _editedContribution.reason = _selectedReason;
      _editedContribution.status = _selectedStatus;
      widget.onSave(_editedContribution);
    } catch (e) {
      print('Error saving contribution: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editing: ${widget.contribution.user.name}'),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<ContributionReason>(
              value: _selectedReason,
              decoration: InputDecoration(
                labelText: 'Reason',
                enabled: _isAdmin,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items:
                  ContributionReason.values.map((reason) {
                    return DropdownMenuItem<ContributionReason>(
                      value: reason,
                      child: Text(reason.name),
                    );
                  }).toList(),
              onChanged:
                  _isAdmin
                      ? (reason) {
                        if (reason != null) {
                          setState(() {
                            _selectedReason = reason;
                          });
                        }
                      }
                      : null,
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<ContributionStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                enabled: _isAdmin,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items:
                  ContributionStatus.values.map((status) {
                    return DropdownMenuItem<ContributionStatus>(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
              onChanged:
                  _isAdmin
                      ? (status) {
                        if (status != null) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        }
                      }
                      : null,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                enabled: _isAdmin,
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
                  onPressed: _isAdmin ? _saveChanges : null,
                  child: const Text('Save'),
                ),
              ],
            ),
            if (!_isAdmin)
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
