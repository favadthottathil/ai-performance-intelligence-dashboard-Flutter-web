import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/screen_metric_model.dart';

class CrashCountChart extends StatelessWidget {
  final List<ScreenMetricModel> metrics;

  const CrashCountChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Check if any screens actually have crash data or just show all if none
    final hasAnyCrashes = metrics.any((m) => m.crashCount > 0);
    // filter so we do not plot endless zeros if they have none
    final validMetrics = hasAnyCrashes
        ? metrics.where((m) => m.crashCount > 0).toList()
        : metrics.take(5).toList();

    final int maxCrashes = validMetrics.isEmpty
        ? 10
        : validMetrics.map((m) => m.crashCount).reduce((a, b) => a > b ? a : b);
    final double maxY = maxCrashes * 1.5;

    if (validMetrics.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No Crash data available')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.report_gmailerrorred_outlined,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Runtime Crashes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: isMobile ? 180 : 250,
            child: BarChart(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              BarChartData(
                maxY: maxY <= 0 ? 5 : maxY, // default height
                alignment: BarChartAlignment.start,
                groupsSpace: 24,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < validMetrics.length) {
                          final originalTitle = validMetrics[value.toInt()]
                              .screen
                              .split(' ')
                              .first;
                          String displayTitle = originalTitle;
                          if (originalTitle.length > 5) {
                            displayTitle = '${originalTitle.substring(0, 4)}..';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Tooltip(
                              message: originalTitle,
                              preferBelow: false,
                              child: SizedBox(
                                width: 32, // limit width explicitly
                                child: Text(
                                  displayTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: const EdgeInsets.symmetric(vertical: 4),
                    tooltipMargin: 12,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: validMetrics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final metric = entry.value;

                  return BarChartGroupData(
                    x: index,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        toY: metric.crashCount.toDouble(),
                        width: isMobile ? 10 : 16,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEF4444), // Red 500
                            const Color(0xFFF87171), // Red 400
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        // backDrawRodData removed locally to prevent the high unselected line
                        backDrawRodData: BackgroundBarChartRodData(show: false),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
