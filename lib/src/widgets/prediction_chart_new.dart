import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;
import '../theme/app_theme.dart';

class PredictionChart extends StatelessWidget {
  final Map<String, int> predictionCounts;
  final Map<String, double> accuracies;

  static const meatCutCategories = {
    'beef_sirloin': 'เนื้อวัวสันนอก',
    'pork_sirloin': 'เนื้อหมูสันนอก',
    'beef_tenderloin': 'เนื้อวัวสันใน',
    'pork_tenderloin': 'เนื้อหมูสันใน',
  };

  const PredictionChart({
    super.key,
    required this.predictionCounts,
    required this.accuracies,
  });

  String _getThaiLabel(String key) {
    return meatCutCategories[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final thaiLabelCounts = Map<String, int>.fromEntries(
      predictionCounts.entries.map(
        (e) => MapEntry(_getThaiLabel(e.key), e.value),
      ),
    );

    final thaiLabelAccuracies = Map<String, double>.fromEntries(
      accuracies.entries.map((e) => MapEntry(_getThaiLabel(e.key), e.value)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'จำนวนการทำนาย',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: thaiLabelCounts.values.fold<int>(0, max) * 1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= thaiLabelCounts.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  thaiLabelCounts.keys.elementAt(value.toInt()),
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                          reservedSize: 80,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: thaiLabelCounts.entries
                        .map(
                          (e) => BarChartGroupData(
                            x: thaiLabelCounts.keys.toList().indexOf(e.key),
                            barRods: [
                              BarChartRodData(
                                toY: e.value.toDouble(),
                                color: AppTheme.primaryColor,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ความแม่นยำ (%)',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    minX: 0,
                    maxX: thaiLabelAccuracies.length - 1.0,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 ||
                                value >= thaiLabelAccuracies.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  thaiLabelAccuracies.keys.elementAt(
                                    value.toInt(),
                                  ),
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                          reservedSize: 80,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppTheme.textMuted.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: thaiLabelAccuracies.entries
                            .map(
                              (e) => FlSpot(
                                thaiLabelAccuracies.keys
                                    .toList()
                                    .indexOf(e.key)
                                    .toDouble(),
                                e.value * 100,
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        color: AppTheme.successColor,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 6,
                                color: AppTheme.successColor,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
