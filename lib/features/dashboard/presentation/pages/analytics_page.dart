import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/widgets/frame_drop_chart.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/widgets/render_time_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return _DashboardContent(state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent(this.state);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1000;

    final analysis = state.analysis;
    final severity = analysis['severity'];

    if (state.summary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No performance data collected yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // KPIs / Severity Header
          _SeverityCard(severity),
          const SizedBox(height: 24),

          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      RenderTimeChart(metrics: state.summary),
                      const SizedBox(height: 24),
                      FrameDropChart(metrics: state.summary),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _InsightsPanel(analysis)),
              ],
            )
          else
            Column(
              children: [
                RenderTimeChart(metrics: state.summary),
                const SizedBox(height: 24),
                FrameDropChart(metrics: state.summary),
                const SizedBox(height: 24),
                _InsightsPanel(analysis),
              ],
            ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _GlassCard({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InsightsPanel extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const _InsightsPanel(this.analysis);

  @override
  Widget build(BuildContext context) {
    List<String> parseList(dynamic list) {
      if (list is! List) return [];
      return list.map((e) {
        if (e is String) return e;
        if (e is Map) {
          return e['message']?.toString() ??
              e['description']?.toString() ??
              e['text']?.toString() ??
              e.toString();
        }
        return e.toString();
      }).toList();
    }

    final issues = parseList(analysis['issues']);
    final recommendations = parseList(analysis['recommendations']);

    return Column(
      children: [
        _Section(
          title: 'Issues Detected',
          items: issues,
          icon: Icons.warning_amber_rounded,
          isError: true,
        ),
        const SizedBox(height: 24),
        _Section(
          title: 'Recommendations',
          items: recommendations,
          icon: Icons.lightbulb_outline,
        ),
      ],
    );
  }
}

class _SeverityCard extends StatelessWidget {
  final String severity;

  const _SeverityCard(this.severity);

  Color get color {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Red 500
      case 'medium':
        return const Color(0xFFF59E0B); // Amber 500
      default:
        return const Color(0xFF10B981); // Emerald 500
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = color;
    return _GlassCard(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.analytics, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Decorative
            Icon(
              Icons.show_chart,
              color: Colors.white.withOpacity(0.1),
              size: 64,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final bool isError;

  const _Section({
    required this.title,
    required this.items,
    required this.icon,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isError
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Text(
                'No items found',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
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
    );
  }
}
