import 'package:flutter/material.dart';
import '../interfaces/contribution.dart';
import '../models/contribution.dart';
import '../utils/constants.dart'; // Assuming this contains AppColors

class ContributionItemDisplayWidget extends StatelessWidget {
  final Contribution contribution;
  final VoidCallback onEdit;
  final bool isAdmin; // Add a flag to indicate if the user is admin

  const ContributionItemDisplayWidget({
    Key? key,
    required this.contribution,
    required this.onEdit,
    required this.isAdmin, // Require the isAdmin flag
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: ${contribution.user.name}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Reason: ${contribution.reason.name}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Amount: \$${contribution.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Status: ${contribution.status.name}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: contribution.status == ContributionStatus.paid
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Only show the edit button if the user is admin
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primaryColor),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}