import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elastik_management/utils/auth_provider.dart';
import 'package:elastik_management/utils/data_loader.dart';
import 'package:elastik_management/widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DailyNews> _dailyNews = [];
  @override
  void initState() {
    _loadNews();
    super.initState();
  }

  // ignore: unused_element
  void _handleLogout(BuildContext context) {
    context.read<AuthProvider>().logout();
  }

  void _loadNews() async {
    List<DailyNews> news = await DataLoader.loadDailyNews();
    if (mounted) {
      // Add this check to prevent setState after disposal
      setState(() {
        _dailyNews = news;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              "Today's News Turn",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _dailyNews.isNotEmpty
              ? NewsCard(
                personName: _dailyNews.first.personName,
                imageUrl: _dailyNews.first.imageUrl,
                date: _dailyNews.first.date,
              )
              : const Center(child: Text("No News Today")),
        ],
      ),
    );
  }
}
