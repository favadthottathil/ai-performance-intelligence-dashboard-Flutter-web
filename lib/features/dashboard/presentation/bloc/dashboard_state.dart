import 'package:ai_performance_intelligence_platform/features/apps/data/models/app_model.dart';
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

  /// Every app the user owns, so the UI can offer a switcher rather than
  /// silently showing only the first one.
  final List<AppModel> apps;

  /// The app currently being displayed.
  final String selectedAppId;

  /// Whether the live metrics stream is currently connected. The UI shows
  /// "Live" only when this is true; otherwise the data is poll-refreshed.
  final bool isLive;

  DashboardLoaded({
    required this.summary,
    required this.analysis,
    required this.apps,
    required this.selectedAppId,
    this.tab = DashboardTab.analytics,
    this.isLive = false,
  });

  DashboardLoaded copyWith({
    List<ScreenMetricModel>? summary,
    AnalysisResult? analysis,
    DashboardTab? tab,
    List<AppModel>? apps,
    String? selectedAppId,
    bool? isLive,
  }) {
    return DashboardLoaded(
      summary: summary ?? this.summary,
      analysis: analysis ?? this.analysis,
      tab: tab ?? this.tab,
      apps: apps ?? this.apps,
      selectedAppId: selectedAppId ?? this.selectedAppId,
      isLive: isLive ?? this.isLive,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    analysis,
    tab,
    apps,
    selectedAppId,
    isLive,
  ];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
