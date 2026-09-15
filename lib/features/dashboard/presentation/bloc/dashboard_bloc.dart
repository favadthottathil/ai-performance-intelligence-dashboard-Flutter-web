import 'dart:async';

import 'package:ai_performance_intelligence_platform/core/constants/api_constants.dart';
import 'package:ai_performance_intelligence_platform/features/apps/data/models/app_model.dart';
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/get_apps_usecase.dart';
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
  final WatchMetrics watchMetrics;

  StreamSubscription<Map<String, dynamic>>? _liveSubscription;
  Timer? _refreshTimer;
  Timer? _coalesceTimer;
  Timer? _reconnectTimer;

  /// Consecutive failed stream connections, used to back off reconnects so a
  /// backend outage is not hammered by every open dashboard tab.
  int _reconnectAttempts = 0;

  String? _appId;
  bool _closed = false;

  DashboardBloc(this.usecase, this.getAppsUseCase, this.watchMetrics)
    : super(DashboardInitial()) {
    on<LoadDashboard>(_loadDashboard);
    on<RefreshDashboard>(_loadDashboard);
    on<SelectApp>(_onSelectApp);
    on<LiveMetricReceived>(_onLiveMetric);
    on<LiveConnectionChanged>(_onLiveConnectionChanged);
    on<ChangeDashboardTab>((event, emit) {
      if (state is DashboardLoaded) {
        emit((state as DashboardLoaded).copyWith(tab: event.tab));
      }
    });

    // Fallback only. The live stream drives updates; this catches the case
    // where SSE is unavailable (a proxy that buffers it, say) so the page
    // still moves, at a cadence that does not hammer the backend.
    _refreshTimer = Timer.periodic(
      ApiConstants.fallbackRefreshInterval,
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

    // Already loaded and this is not a refresh: nothing to do.
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

      // Keep the user's chosen app across refreshes; fall back to the first
      // only when nothing is selected or the selection no longer exists.
      final selectedId = _resolveSelectedApp(apps, previousState);

      final insights = await usecase(selectedId);

      final currentTab = previousState is DashboardLoaded
          ? previousState.tab
          : DashboardTab.analytics;

      final wasLive = previousState is DashboardLoaded
          ? previousState.isLive
          : false;

      emit(
        DashboardLoaded(
          summary: insights.summary,
          analysis: insights.analysis,
          apps: apps,
          selectedAppId: selectedId,
          tab: currentTab,
          isLive: wasLive,
        ),
      );

      _ensureLiveSubscription(selectedId);
    } catch (e) {
      // A background refresh failing shouldn't disrupt data already on
      // screen — leave it be and try again on the next tick.
      if (isBackgroundRefresh) return;

      if (_looksLikeNoData(e)) {
        emit(DashboardError('No apps found'));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  String _resolveSelectedApp(List<AppModel> apps, DashboardState previous) {
    final desired =
        _appId ?? (previous is DashboardLoaded ? previous.selectedAppId : null);

    if (desired != null && apps.any((a) => a.id == desired)) {
      return desired;
    }
    return apps.first.id;
  }

  static bool _looksLikeNoData(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('404') ||
        text.contains('no data') ||
        text.contains('not found');
  }

  Future<void> _onSelectApp(
    SelectApp event,
    Emitter<DashboardState> emit,
  ) async {
    if (_appId == event.appId) return;

    _appId = event.appId;

    // The previous app's stream is no longer relevant.
    await _cancelLiveSubscription();

    final previousState = state;
    if (previousState is! DashboardLoaded) {
      add(RefreshDashboard());
      return;
    }

    emit(previousState.copyWith(selectedAppId: event.appId, isLive: false));

    try {
      final insights = await usecase(event.appId);
      final current = state;
      if (current is! DashboardLoaded) return;

      emit(
        current.copyWith(
          summary: insights.summary,
          analysis: insights.analysis,
        ),
      );

      _ensureLiveSubscription(event.appId);
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Opens the live stream for [appId], replacing any existing subscription.
  void _ensureLiveSubscription(String appId) {
    if (_closed) return;
    if (_liveSubscription != null && _appId == appId) return;

    _appId = appId;
    _reconnectTimer?.cancel();

    _liveSubscription?.cancel();
    _liveSubscription = watchMetrics(appId).listen(
      (_) {
        _reconnectAttempts = 0;
        add(LiveConnectionChanged(true));
        add(LiveMetricReceived());
      },
      onError: (Object _) => _handleStreamDropped(appId),
      onDone: () => _handleStreamDropped(appId),
      cancelOnError: true,
    );

    add(LiveConnectionChanged(true));
  }

  void _handleStreamDropped(String appId) {
    if (_closed) return;

    add(LiveConnectionChanged(false));

    _liveSubscription?.cancel();
    _liveSubscription = null;

    // Exponential backoff, capped, so a sustained outage settles into
    // infrequent retries rather than a reconnect storm.
    _reconnectAttempts++;
    final delaySeconds = (1 << (_reconnectAttempts - 1)).clamp(1, 60);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_closed || _appId != appId) return;
      _ensureLiveSubscription(appId);
    });
  }

  /// Metrics arrive one per ingested event, which can be many per second.
  /// Refetching per event would stampede the backend, so arrivals are
  /// coalesced into at most one refresh per window.
  void _onLiveMetric(LiveMetricReceived event, Emitter<DashboardState> emit) {
    if (_coalesceTimer?.isActive ?? false) return;

    _coalesceTimer = Timer(ApiConstants.liveCoalesceWindow, () {
      if (_closed) return;
      add(RefreshDashboard());
    });
  }

  void _onLiveConnectionChanged(
    LiveConnectionChanged event,
    Emitter<DashboardState> emit,
  ) {
    final current = state;
    if (current is DashboardLoaded && current.isLive != event.connected) {
      emit(current.copyWith(isLive: event.connected));
    }
  }

  Future<void> _cancelLiveSubscription() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final sub = _liveSubscription;
    _liveSubscription = null;
    await sub?.cancel();
  }

  @override
  Future<void> close() async {
    _closed = true;
    _refreshTimer?.cancel();
    _coalesceTimer?.cancel();
    await _cancelLiveSubscription();
    return super.close();
  }
}
