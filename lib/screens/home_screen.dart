import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elastik_management/utils/auth_provider.dart';
import 'package:elastik_management/models/contribution.dart';
import 'package:elastik_management/models/stock_item.dart';
import 'package:elastik_management/utils/data_loader.dart';
import 'package:elastik_management/widgets/news_card.dart';
import 'package:elastik_management/widgets/overview_card_widget.dart';

import '../interfaces/contribution.dart';
import '../interfaces/stocks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StockItem> _stockItems = [];
  List<DailyNews> _dailyNews = [];
  List<Contribution> _contributions = [];

  @override
  void initState() {
    _loadStockData();
    _loadContributionData();

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

  void _loadStockData() async {
    List<StockItem> stockItems = await DataLoader.loadStockItems();
    if (mounted) {
      // Add this check to prevent setState after disposal
      setState(() {
        _stockItems = stockItems;
      });
    }
  }

  void _loadContributionData() async {
    List<Contribution> contributions = await DataLoader.loadContributions();
    if (mounted) {
      setState(() {
        _contributions = contributions;
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OverviewCardWidget(
                  title: 'Snacks Overview',
                  data: _getStockStatusBreakdown(),
                ),
              ),

              ..._buildUnavailableItemsList(),

              const SizedBox(width: 16),
              Expanded(
                child: OverviewCardWidget(
                  title: 'Contributions Overview',
                  data: _getContributionStatusBreakdown(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getStockStatusBreakdown() {
    Map<StockStatus, int> statusCounts = {};
    for (var item in _stockItems) {
      statusCounts.update(item.status, (value) => value + 1, ifAbsent: () => 1);
    }

    return statusCounts.entries
        .map(
          (entry) => {'label': entry.key.name, 'value': entry.value.toDouble()},
        )
        .toList();
  }

  List<Map<String, dynamic>> _getContributionStatusBreakdown() {
    Map<ContributionStatus, double> statusAmounts = {};
    for (var item in _contributions) {
      statusAmounts.update(
        item.status,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }

    return statusAmounts.entries
        .map((entry) => {'label': entry.key.name, 'value': entry.value})
        .toList();
  }

  List<StockItem> get _unavailableEssentialItems {
    return _stockItems
        .where(
          (item) =>
              (item.category == StockCategory.essentials ||
                  item.category == StockCategory.hygiene) &&
              item.status == StockStatus.unavailable,
        )
        .toList();
  }

  List<Widget> _buildUnavailableItemsList() {
    final unavailableItems = _unavailableEssentialItems;
    if (unavailableItems.isEmpty) {
      return [];
    }
    return [
      const Text(
        'Unavailable Essential and Hygiene Items:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ...unavailableItems.map((item) => Text('- ${item.name}')).toList(),
    ];
  }
}
