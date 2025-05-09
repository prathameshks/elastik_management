import 'dart:convert';
import 'dart:io';
import 'package:elastik_management/models/stock_item.dart';
import 'package:elastik_management/interfaces/contribution.dart';
import 'package:elastik_management/models/contribution.dart';
import 'package:elastik_management/models/wfo_schema.dart';
// import 'package:elastik_management/models/wfo_schema.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user.dart';
import 'package:path_provider/path_provider.dart';

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
    final String response = await _readJsonData('lib/data/daily_news.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => DailyNews.fromJson(item)).toList();
  }

  static Future<List<WFOSchema>> loadWFOSchemas() async {
    final String response = await _readJsonData('lib/data/wfo_schemas.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => WFOSchema.fromJson(item)).toList();
  }

  static Future<Map<WFOSchema, List<User>>> loadUsersForWfoSchedule() async {
    final String usersResponse = await _readJsonData('lib/data/users.json');
    final List<dynamic> usersData = json.decode(usersResponse);

    // Load all WFO schemas first
    final String wfoSchemaResponse = await _readJsonData(
      'lib/data/wfo_schemas.json',
    );
    final List<dynamic> wfoSchemasData = json.decode(wfoSchemaResponse);
    final List<WFOSchema> wfoSchemas =
        wfoSchemasData.map((item) => WFOSchema.fromJson(item)).toList();

    // Process each user JSON to include the full WFOSchema object
    List<User> allUsers = [];
    for (var userJson in usersData) {
      // get WFO Schema by ID and add to JSON
      final wfoSchemaId = userJson['wfoSchema'];

      final WFOSchemaJson = wfoSchemasData.firstWhere(
        (schema) => schema['id'] == wfoSchemaId,
        orElse: () => null,
      );

      if (WFOSchemaJson != null) {
        // Replace the ID with the full schema object
        userJson['wfoSchema'] = WFOSchemaJson;

        // Now create the User object with the proper schema
        allUsers.add(User.fromJson(userJson));
      } else {
        print(
          'Warning: WFO Schema not found for user ${userJson['name']} with ID $wfoSchemaId',
        );
      }
    }

    // Group users by schema
    final Map<WFOSchema, List<User>> usersBySchema = {};

    // Initialize the map with empty lists for each schema
    for (var schema in wfoSchemas) {
      usersBySchema[schema] = [];
    }

    // Add users to their respective schema lists
    for (var user in allUsers) {
      final schemaMatch = wfoSchemas.firstWhere(
        (schema) => schema.id == user.wfoSchema.id,
        orElse: () => WFOSchema.defaultSchema(),
      );

      usersBySchema[schemaMatch]?.add(user);
    }

    return usersBySchema;
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      final String response = await _readJsonData('lib/data/users.json');
      final List<dynamic> users = json.decode(response);
      final userJson = users.firstWhere(
        (user) => user['email'].toLowerCase() == email.toLowerCase(),
        orElse: () => null,
      );

      if (userJson == null) {
        return null;
      }

      // get WFO Schema BY ID and add to Json
      final wfoSchemaId = userJson['wfoSchema'];
      final String wfoSchemaResponse = await _readJsonData(
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
    // Get the document directory path
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/stock_items.json';
    final file = File(path);
    try {
      // Convert items to JSON and save to the file
      final jsonData = stockItems.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      await file.writeAsString(jsonString);

      print('Stock items updated successfully to $path');

      // Load the updated data next time the app starts
      // We might want to also copy this to the app bundle (for development only)
      // if (const bool.fromEnvironment('dart.vm.product') == false) {
      //   _tryCopyToAppBundle(jsonString, 'lib/data/stock_items.json');
      // }
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
    return status == 'paid'
        ? ContributionStatus.paid
        : ContributionStatus.unpaid;
  }

  static Future<List<Contribution>> loadContributions() async {
    final String response = await _readJsonData('lib/data/contributions.json');
    final List<dynamic> data = json.decode(response);
    return await Future.wait(
      data.map((item) async {
        // Load user details for each contribution
        final user = await getUserByUserId(item['user']);
        return Contribution(
          id: item['id'],
          reason: _parseContributionReason(item['reason']),
          amount: item['amount'],
          user: user!, // Assuming user is found, handle null if necessary
          status: _parseContributionStatus(item['status']),
        );
      }),
    );
  }

  static Future<User?> getUserByUserId(int id) async {
    try {
      final String response = await _readJsonData('lib/data/users.json');
      final List<dynamic> users = json.decode(response);
      final userJson = users.firstWhere((user) => user['id'] == id);

      if (userJson == null) return null;

      // get WFO Schema BY ID and add to Json
      final wfoSchemaId = userJson['wfoSchema'];
      final String wfoSchemaResponse = await _readJsonData(
        'lib/data/wfo_schemas.json',
      );
      final List<dynamic> wfoSchemas = json.decode(wfoSchemaResponse);

      final WFOSchemaJson = wfoSchemas.firstWhere(
        (schema) => schema['id'] == wfoSchemaId,
        orElse: () => null,
      );

      userJson['wfoSchema'] = WFOSchemaJson;

      return User.fromJson(userJson);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  static Future<void> updateContributions(
    List<Contribution> contributions,
  ) async {
    try {
      // Get the document directory path
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/contributions.json';
      final file = File(path);

      // Convert contributions to JSON and save to the file
      final jsonData = contributions.map((item) => item.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));

      print('Contributions updated successfully to $path');

      // Load the updated data next time the app starts
      // We might want to also copy this to the app bundle (for development only)
      // if (const bool.fromEnvironment('dart.vm.product') == false) {
      //   _tryCopyToAppBundle(
      //     jsonEncode(jsonData),
      //     'lib/data/contributions.json',
      //   );
      // }
    } catch (e) {
      print('Error updating contributions: $e');
      // Handle error - perhaps show a user message
    }
  }

  // Helper method to copy data to app bundle for development
  // ignore: unused_element
  static Future<void> _tryCopyToAppBundle(String data, String path) async {
    try {
      // This is only for development - writing to the app bundle
      // It won't work in production but helps during development
      final appFile = File(path);
      await appFile.writeAsString(data);
      print('Also copied to app bundle at $path');
    } catch (e) {
      print('Could not copy to app bundle: $e');
    }
  }

  static Future<List<StockItem>> loadStockItems() async {
    final String response = await _readJsonData('lib/data/stock_items.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => StockItem.fromJson(item)).toList();
  }

  // Replace the existing _readJsonData method with this improved version:
  static Future<String> _readJsonData(String bundlePath) async {
    try {
      // Get the local path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = bundlePath.split('/').last;
      final path = '${directory.path}/$fileName';
      final file = File(path);

      // Check if file exists in local storage
      if (await file.exists()) {
        print('Reading $fileName from local storage');
        return await file.readAsString();
      }

      // File doesn't exist locally, read from bundle
      print('File $fileName not found in local storage, reading from bundle');
      final bundleData = await rootBundle.loadString(bundlePath);

      // Copy the bundle data to local storage for future use
      try {
        // Ensure the directory exists
        await directory.create(recursive: true);

        // Write the file
        await file.writeAsString(bundleData);
        print('Created local copy of $fileName for future use');
      } catch (writeError) {
        // If we fail to write, it's not fatal - just log it
        print('Warning: Could not create local copy of $fileName: $writeError');
      }

      return bundleData;
    } catch (e) {
      // If all fails, fall back to bundle as last resort
      print('Error accessing file: $e, falling back to bundle');
      return await rootBundle.loadString(bundlePath);
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
