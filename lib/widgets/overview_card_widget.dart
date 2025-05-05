import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Using fl_chart as an example

class OverviewCardWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const OverviewCardWidget({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildPieChartSections(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildLegend(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (data.isEmpty) {
      return [];
    }

    double totalValue = data.fold(0.0, (sum, item) => sum + (item['value'] as double));

    return data.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> item = entry.value;
      double value = item['value'] as double;
      String label = item['label'] as String;

      // Assign different colors for each section (you can improve this)
      Color color = Colors.blueGrey[(index + 1) * 100] ?? Colors.blueGrey;
      if (index == 0) color = Colors.blue;
      if (index == 1) color = Colors.green;
      if (index == 2) color = Colors.orange;


      return PieChartSectionData(
        color: color,
        value: value,
        title: '${((value / totalValue) * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    return data.map((item) {
      String label = item['label'] as String;
      double value = item['value'] as double;

      // Find the corresponding color from the pie chart sections (basic approach)
      Color legendColor = Colors.blueGrey; // Default color
       int index = data.indexOf(item);
       legendColor = Colors.blueGrey[(index + 1) * 100] ?? Colors.blueGrey;
        if (index == 0) legendColor = Colors.blue;
        if (index == 1) legendColor = Colors.green;
        if (index == 2) legendColor = Colors.orange;


      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: legendColor,
            ),
            const SizedBox(width: 8.0),
            Text('$label: ${value.toStringAsFixed(2)}'),
          ],
        ),
      );
    }).toList();
  }
}