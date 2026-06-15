import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/screen_metric_model.dart';

class FrameDropChart extends StatelessWidget {
  final List<ScreenMetricModel> metrics;

  const FrameDropChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final validMetrics = metrics.where((m) => m.frameDrops > 0).toList();
    final double maxFrameDrops = validMetrics.isEmpty
        ? 100.0
        : validMetrics
              .map((m) => m.frameDrops)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();
    final double maxY = maxFrameDrops * 1.2;

    if (validMetrics.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No frame drop data')),
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
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Frame Drops Impact',
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
                maxY: maxY,
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
                        '${rod.toY.toInt()} drops',
                        const TextStyle(
                          color: Colors.redAccent,
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
                        toY: metric.frameDrops.toDouble(),
                        gradient: LinearGradient(
                          colors: [
                            Colors.redAccent,
                            Colors.redAccent.withOpacity(0.5),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: isMobile ? 10 : 16,
                        borderRadius: BorderRadius.circular(4),
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
