import 'package:flutter/material.dart';
import 'package:elastik_management/utils/data_loader.dart';
import 'package:elastik_management/widgets/news_card.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<DailyNews>>(
        future: DataLoader.loadDailyNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading news: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final news = snapshot.data![index];
              return Dismissible(
                key: Key(news.id.toString()),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  // Handle dismiss if needed
                },
                child: NewsCard(
                  personName: news.personName,
                  imageUrl: news.imageUrl,
                  date: news.date,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
