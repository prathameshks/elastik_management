import '../interfaces/contribution.dart';

import '../models/user.dart';

class Contribution {
  final int id;
  final User user;
  double amount;
  ContributionReason reason;
  ContributionStatus status = ContributionStatus.unpaid;

  Contribution({
    required this.id,
    required this.reason,
    required this.amount,
    required this.user, required ContributionStatus status,
  });
}
