import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/analysis_result.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/screen_metric_model.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashbaord_tab.dart';
import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<ScreenMetricModel> summary;

  final AnalysisResult analysis;

  final DashboardTab tab;

  DashboardLoaded({
    required this.summary,
    required this.analysis,
    this.tab = DashboardTab.analytics,
  });

  DashboardLoaded copyWith({DashboardTab? tab}) {
    return DashboardLoaded(
      summary: summary,
      analysis: analysis,
      tab: tab ?? this.tab,
    );
  }

  @override
  List<Object?> get props => [summary, analysis, tab];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
