import 'dart:async';

import 'package:ai_performance_intelligence_platform/core/constants/api_constants.dart';
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/get_apps_usecase.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/analysis_result.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashbaord_tab.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardInsights usecase;
  final GetAppsUseCase getAppsUseCase;

  Timer? _refreshTimer;

  DashboardBloc(this.usecase, this.getAppsUseCase) : super(DashboardInitial()) {
    on<LoadDashboard>(_loadDashboard);
    on<RefreshDashboard>(_loadDashboard);
    on<ChangeDashboardTab>((event, emit) {
      if (state is DashboardLoaded) {
        emit((state as DashboardLoaded).copyWith(tab: event.tab));
      }
    });

    // Keep the dashboard live by periodically re-fetching the summary and
    // AI analysis in the background, without disrupting the current view.
    _refreshTimer = Timer.periodic(
      ApiConstants.refreshInterval,
      (_) => add(RefreshDashboard()),
    );
  }

  Future<void> _loadDashboard(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final previousState = state;
    final isBackgroundRefresh =
        event is RefreshDashboard && previousState is DashboardLoaded;

    // If we are already loaded and not forcing a refresh, skip the API call
    if (previousState is DashboardLoaded && event is! RefreshDashboard) {
      return;
    }

    if (!isBackgroundRefresh) {
      emit(DashboardLoading());
    }

    try {
      final apps = await getAppsUseCase();
      if (apps.isEmpty) {
        if (!isBackgroundRefresh) {
          emit(DashboardError('No apps found'));
        }
        return;
      }

      final appId = apps.first.id;
      final insights = await usecase(appId);

      final currentTab = previousState is DashboardLoaded
          ? previousState.tab
          : DashboardTab.analytics;

      // Always emit DashboardLoaded, even if summary is empty
      // The UI will handle the empty state with a friendly message
      emit(
        DashboardLoaded(
          summary: insights.summary,
          analysis: insights.analysis,
          tab: currentTab,
        ),
      );
    } catch (e) {
      // A background refresh failing shouldn't disrupt the currently
      // displayed data - just leave it as-is and try again next tick.
      if (isBackgroundRefresh) {
        return;
      }

      // Check if the error is due to no data (404 or similar)
      // If so, emit an empty DashboardLoaded instead of an error
      if (e.toString().contains('404') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found')) {
        final currentTab = previousState is DashboardLoaded
            ? previousState.tab
            : DashboardTab.analytics;

        emit(
          DashboardLoaded(
            summary: [],
            analysis: AnalysisResult.empty(),
            tab: currentTab,
          ),
        );
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
