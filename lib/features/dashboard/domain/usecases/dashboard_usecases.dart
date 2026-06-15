import 'package:injectable/injectable.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/screen_metric_model.dart';
import '../repositories/dashboard_repository.dart';

/// Combined result of fetching a screen-by-screen summary and the
/// AI-generated analysis for an app.
class DashboardInsights {
  final List<ScreenMetricModel> summary;
  final AnalysisResult analysis;

  DashboardInsights({required this.summary, required this.analysis});
}

@lazySingleton
class GetDashboardInsights {
  final DashboardRepository repository;

  GetDashboardInsights(this.repository);

  Future<DashboardInsights> call(String appId) async {
    final summaryRaw = await repository.getSummary(appId);
    final analysisRaw = await repository.analyze(appId);

    final summary = summaryRaw
        .map<ScreenMetricModel>(
          (e) => ScreenMetricModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    return DashboardInsights(
      summary: summary,
      analysis: AnalysisResult.fromJson(analysisRaw),
    );
  }
}
