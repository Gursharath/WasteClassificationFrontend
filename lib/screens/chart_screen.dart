import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('predictions');
    final data = box.values.cast<Map>().toList();

    // Debug: Print the data to see what's in the box
    print('Total entries in box: ${data.length}');
    for (var item in data) {
      print('Item: $item');
      print('Label: ${item['label']}');
    }

    final organic = data.where((d) => d['label'] == "Organic").length;
    final recyclable = data.where((d) => d['label'] == "Recyclable").length;
    final total = organic + recyclable;

    print('Organic count: $organic');
    print('Recyclable count: $recyclable');
    print('Total count: $total');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body:
          total == 0
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No data to show",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start classifying waste to see analytics",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.green[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.eco,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$organic',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const Text(
                                    'Organic',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            color: Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.recycling,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$recyclable',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Text(
                                    'Recyclable',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart Title
                    const Text(
                      "Waste Classification Distribution",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pie Chart
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: organic.toDouble(),
                              color: Colors.green,
                              title:
                                  organic > 0
                                      ? '${((organic / total) * 100).toStringAsFixed(1)}%'
                                      : '',
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 80,
                              showTitle: organic > 0,
                            ),
                            PieChartSectionData(
                              value: recyclable.toDouble(),
                              color: Colors.blue,
                              title:
                                  recyclable > 0
                                      ? '${((recyclable / total) * 100).toStringAsFixed(1)}%'
                                      : '',
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 80,
                              showTitle: recyclable > 0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Legend
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Organic ($organic)'),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Recyclable ($recyclable)'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
    );
  }
}
