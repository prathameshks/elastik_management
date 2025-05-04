import 'package:flutter/material.dart';
import 'package:elastik_management/utils/constants.dart';
import 'package:intl/intl.dart';

class NewsCard extends StatelessWidget {
  final String personName;
  final String imageUrl;
  final DateTime date;

  const NewsCard({
    super.key,
    required this.personName,
    required this.imageUrl,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: AppColors.backgroundColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(
            personName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          subtitle: Text(
            DateFormat('EEEE, MMMM d, y').format(date),
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}