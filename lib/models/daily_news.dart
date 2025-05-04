class DailyNews {
  final int id;
  final String personName;
  final String dateOfNews;
  final String profilePicUrl;

  DailyNews({
    required this.id,
    required this.personName,
    required this.dateOfNews,
    required this.profilePicUrl,
  });

  factory DailyNews.fromJson(Map<String, dynamic> json) {
    return DailyNews(
      id: json['id'] as int,
      personName: json['person_name'] as String,
      dateOfNews: json['date_of_news'] as String,
      profilePicUrl: json['profilepic_url'] as String,
    );
  }
}