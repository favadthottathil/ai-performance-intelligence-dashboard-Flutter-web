import 'package:ai_performance_intelligence_platform/core/widgets/hover_scale.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/screen_metric_model.dart';
import 'package:flutter/material.dart';

/// A row of at-a-glance KPI cards summarizing the currently loaded metrics.
class StatsOverview extends StatelessWidget {
  final List<ScreenMetricModel> metrics;

  const StatsOverview({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final screenCount = metrics.length;
    final avgRenderTime = screenCount == 0
        ? 0.0
        : metrics.map((m) => m.avgRenderTime).reduce((a, b) => a + b) /
              screenCount;
    final totalFrameDrops = metrics.fold<int>(
      0,
      (sum, m) => sum + m.frameDrops,
    );
    final totalCrashes = metrics.fold<int>(
      0,
      (sum, m) => sum + m.crashCount,
    );

    final stats = [
      _StatData(
        icon: Icons.phone_iphone_rounded,
        label: 'Screens Monitored',
        value: '$screenCount',
        color: const Color(0xFF3B82F6),
      ),
      _StatData(
        icon: Icons.timer_outlined,
        label: 'Avg Render Time',
        value: '${avgRenderTime.toStringAsFixed(1)} ms',
        color: const Color(0xFF06B6D4),
      ),
      _StatData(
        icon: Icons.warning_amber_rounded,
        label: 'Total Frame Drops',
        value: '$totalFrameDrops',
        color: const Color(0xFFF59E0B),
      ),
      _StatData(
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Total Crashes',
        value: '$totalCrashes',
        color: const Color(0xFFEF4444),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 4;
        if (width < 900) columns = 2;
        if (width < 420) columns = 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: columns == 1 ? 3.2 : 1.8,
          ),
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        );
      },
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
