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
    // The summary is the page's primary content and the AI analysis is
    // supplementary, so they are issued concurrently rather than serially.
    final summaryFuture = repository.getSummary(appId);
    final analysisFuture = repository.analyze(appId);

    // Attached up front so a failing analysis can never surface as an
    // unhandled async error while the summary is still in flight.
    final guardedAnalysis = analysisFuture.then<AnalysisResult>(
      AnalysisResult.fromJson,
      onError: (_, __) => AnalysisResult.empty(),
    );

    final summaryRaw = await summaryFuture;

    final summary = <ScreenMetricModel>[];
    for (final entry in summaryRaw) {
      if (entry is Map<String, dynamic>) {
        summary.add(ScreenMetricModel.fromJson(entry));
      }
    }

    return DashboardInsights(summary: summary, analysis: await guardedAnalysis);
  }
}

/// Subscribes to the backend's live metrics stream for an app.
@lazySingleton
class WatchMetrics {
  final DashboardRepository repository;

  WatchMetrics(this.repository);

  Stream<Map<String, dynamic>> call(String appId) =>
      repository.watchMetrics(appId);
}
