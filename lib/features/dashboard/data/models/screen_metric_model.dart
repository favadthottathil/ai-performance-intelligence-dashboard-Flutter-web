class ScreenMetricModel {
  final String screen;
  final double avgRenderTime;
  final int frameDrops;
  final double avgApiLatency;
  final int apiFailureCount;
  final int crashCount;

  ScreenMetricModel({
    required this.screen,
    required this.avgRenderTime,
    required this.frameDrops,
    required this.avgApiLatency,
    required this.apiFailureCount,
    required this.crashCount,
  });

  factory ScreenMetricModel.fromJson(Map<String, dynamic> json) {
    return ScreenMetricModel(
      screen: json['screen'],
      avgRenderTime: (json['avg_render_time_ms'] as num).toDouble(),
      frameDrops: json['total_frame_drops'],
      avgApiLatency: (json['avg_api_latency_ms'] as num?)?.toDouble() ?? 0.0,
      apiFailureCount: json['api_failure_count'] ?? 0,
      crashCount: json['crash_count'] ?? 0,
    );
  }
}
