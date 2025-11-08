import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;

class PredictionChart extends StatelessWidget {
  final Map<String, int> predictionCounts;
  final Map<String, double> accuracies;

  const PredictionChart({
    super.key,
    required this.predictionCounts,
    required this.accuracies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: predictionCounts.values.fold<int>(0, max) * 1.2,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          predictionCounts.keys.elementAt(value.toInt()),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
              barGroups: predictionCounts.entries
                  .map(
                    (e) => BarChartGroupData(
                      x: predictionCounts.keys.toList().indexOf(e.key),
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: accuracies.length - 1.0,
              minY: 0,
              maxY: 100,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          accuracies.keys.elementAt(value.toInt()),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: accuracies.entries
                      .map(
                        (e) => FlSpot(
                          accuracies.keys.toList().indexOf(e.key).toDouble(),
                          e.value,
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
