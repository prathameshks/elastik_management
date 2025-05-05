import 'dart:convert';
import 'dart:io';
import 'package:elastik_management/interfaces/contribution.dart';
import 'package:elastik_management/models/contribution.dart';
import 'package:elastik_management/models/stock_item.dart';
// import 'package:elastik_management/models/wfo_schema.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:elastik_management/models/user.dart';

class DailyNews {
  final int id;
  final String personName;
  final String imageUrl;
  final DateTime date;

  DailyNews({
    required this.id,
    required this.personName,
    required this.imageUrl,
    required this.date,
  });

  factory DailyNews.fromJson(Map<String, dynamic> json) {
    return DailyNews(
      id: json['id'],
      personName: json['personName'],
      imageUrl: json['profilePicUrl'],
      date: DateTime.parse(json['dateOfNews']),
    );
  }
}

class DataLoader {
  static Future<List<DailyNews>> loadDailyNews() async {
    final String response = await rootBundle.loadString(
      'lib/data/daily_news.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((item) => DailyNews.fromJson(item)).toList();
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      final String response = await rootBundle.loadString(
        'lib/data/users.json',
      );
      final List<dynamic> users = json.decode(response);
      final userJson = users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => null,
      );

      if (userJson == null) {
        return null;
      }

      // get WFO Schema BY ID and add to Json
      final wfoSchemaId = userJson['wfoSchema'];
      final String wfoSchemaResponse = await rootBundle.loadString(
        'lib/data/wfo_schemas.json',
      );
      final List<dynamic> wfoSchemas = json.decode(wfoSchemaResponse);

      final WFOSchemaJson = wfoSchemas.firstWhere(
        (schema) => schema['id'] == wfoSchemaId,
        orElse: () => null,
      );

      userJson['wfoSchema'] = WFOSchemaJson;

      // Convert the userJson to a User object
      return User.fromJson(userJson);
    } catch (e) {
      print('Error loading user: $e');
      return null;
    }
  }

  static Future<void> updateStockItems(List<StockItem> stockItems) async {
    try {
      final file = File('lib/data/stock_items.json');
      final jsonData = stockItems.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      await file.writeAsString(jsonString);
      print('Stock items updated successfully.');
    } catch (e) {
      print('Error updating stock items: $e');
      // Handle the error appropriately, e.g., show an error message to the user
    }
  }

  static ContributionReason _parseContributionReason(String reason) {
    switch (reason) {
      case 'fridayTShirt':
        return ContributionReason.fridayTShirt;
      case 'missedNews':
        return ContributionReason.missedNews;
      case 'wfoMissed':
        return ContributionReason.wfoMissed;
      case 'other':
        return ContributionReason.other;
      default:
        return ContributionReason.other;
    }
  }
  static ContributionStatus _parseContributionStatus(String status) {
    return status == 'paid' ? ContributionStatus.paid : ContributionStatus.unpaid;
  }

  static Future<List<Contribution>> loadContributions() async {
    final String response = await rootBundle.loadString(
      'lib/data/contributions.json',
    );
    final List<dynamic> data = json.decode(response);
    return await Future.wait(data.map((item) async {
      // Load user details for each contribution
      final user = await getUserByUserId(item['user']);
      return Contribution(
        id: item['id'],
        reason: _parseContributionReason(item['reason']),
        amount: item['amount'],
        user: user!, // Assuming user is found, handle null if necessary
        status: _parseContributionStatus(item['status']),
      );
    }));
  }

  static Future<User?> getUserByUserId(int id) async {
    try {
      final String response = await rootBundle.loadString(
        'lib/data/users.json',
      );
      final List<dynamic> users = json.decode(response);
      final userJson = users.firstWhere((user) => user['id'] == id);
      return User.fromJson(userJson);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  static Future<void> updateContributions(List<Contribution> contributions) async {
    try {
      final file = File('lib/data/contributions.json');
      final jsonData = contributions.map((item) => item.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error updating contributions: $e');
    }
  }
}

extension ContributionExtension on Contribution {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.id,
      'reason': _contributionReasonToString(reason),
      'amount': amount,
      'status': _contributionStatusToString(status),
    };
  }

  String _contributionReasonToString(ContributionReason reason) {
    return reason.toString().split('.').last;
  }

  String _contributionStatusToString(ContributionStatus status) {
    return status.toString().split('.').last;
  }
}
