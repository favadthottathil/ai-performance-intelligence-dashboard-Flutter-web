import 'package:ai_performance_intelligence_platfrom/features/apps/domain/usecases/get_apps_usecase.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/data/models/screen_metric_model.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashbaord_tab.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardInsights usecase;
  final GetAppsUseCase getAppsUseCase;

  DashboardBloc(this.usecase, this.getAppsUseCase) : super(DashboardInitial()) {
    on<LoadDashboard>(_loadDashboard);
    on<RefreshDashboard>(_loadDashboard);
    on<ChangeDashboardTab>((event, emit) {
      if (state is DashboardLoaded) {
        emit((state as DashboardLoaded).copyWith(tab: event.tab));
      }
    });
  }

  Future<void> _loadDashboard(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // If we are already loaded and not forcing a refresh, skip the API call
    if (state is DashboardLoaded && event is! RefreshDashboard) {
      return;
    }

    emit(DashboardLoading());
    try {
      final apps = await getAppsUseCase();
      if (apps.isEmpty) {
        emit(DashboardError('No apps found'));
        return;
      }

      final appId = apps.first.id;
      final result = await usecase(appId);

      final summaryRaw = result['summary'] as List;

      final summary = summaryRaw
          .map<ScreenMetricModel>((e) => ScreenMetricModel.fromJson(e))
          .toList();

      final currentTab = state is DashboardLoaded
          ? (state as DashboardLoaded).tab
          : DashboardTab.analytics;

      // Always emit DashboardLoaded, even if summary is empty
      // The UI will handle the empty state with a friendly message
      emit(
        DashboardLoaded(
          summary: summary,
          analysis: result['analysis'] ?? {},
          tab: currentTab,
        ),
      );
    } catch (e) {
      // Check if the error is due to no data (404 or similar)
      // If so, emit an empty DashboardLoaded instead of an error
      if (e.toString().contains('404') ||
          e.toString().toLowerCase().contains('no data') ||
          e.toString().toLowerCase().contains('not found')) {
        final currentTab = state is DashboardLoaded
            ? (state as DashboardLoaded).tab
            : DashboardTab.analytics;

        emit(DashboardLoaded(summary: [], analysis: {}, tab: currentTab));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }
}
