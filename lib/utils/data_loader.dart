import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final String response = await rootBundle.loadString('lib/data/users.json');
    final List<dynamic> users = json.decode(response);
    return users.firstWhere(
          (user) => user['email'] == email,
          orElse: () => null,
        )
        as Map<String, dynamic>?;
  }
}
