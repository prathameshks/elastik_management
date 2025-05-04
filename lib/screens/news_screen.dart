import 'package:flutter/material.dart';
import 'package:elastik_management/utils/data_loader.dart';
import 'package:elastik_management/widgets/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Center(child: Text('News Turns')),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: NewsCardStack(),
      ),
    );
  }
}

class NewsCardStack extends StatefulWidget {
  const NewsCardStack({super.key});

  @override
  _NewsCardStackState createState() => _NewsCardStackState();
}

class _NewsCardStackState extends State<NewsCardStack> {
  List<DailyNews> _newsItems = [];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() async {
    List<DailyNews> news = await DataLoader.loadDailyNews();
    setState(() {
      _newsItems = news;
    });
  }

  void _removeTopCard() {
    setState(() {
      _newsItems.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _newsItems.map((news) {
        return Dismissible(
          key: Key(news.id.toString()),
          onDismissed: (direction) {
            _removeTopCard();
          },
          child: NewsCard(personName: news.personName, imageUrl: news.imageUrl, date: news.date),
        );
      }).toList(),
    );
  }
}