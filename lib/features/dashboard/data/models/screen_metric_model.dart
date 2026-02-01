class ScreenMetricModel {
  final String screen;
  final double avgRenderTime;
  final int frameDrops;

  ScreenMetricModel({
    required this.screen,
    required this.avgRenderTime,
    required this.frameDrops,
  });

  factory ScreenMetricModel.fromJson(Map<String, dynamic> json) {
    return ScreenMetricModel(
      screen: json['screen'],
      avgRenderTime:
          (json['avg_render_time_ms'] as num).toDouble(),
      frameDrops: json['total_frame_drops'],
    );
  }
}
