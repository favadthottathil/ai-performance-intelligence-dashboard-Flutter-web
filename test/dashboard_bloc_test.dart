import 'dart:async';

import 'package:ai_performance_intelligence_platform/features/apps/data/models/app_model.dart';
import 'package:ai_performance_intelligence_platform/features/apps/domain/usecases/get_apps_usecase.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/analysis_result.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/screen_metric_model.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashbaord_tab.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDashboardInsights extends Mock implements GetDashboardInsights {}

class MockGetAppsUseCase extends Mock implements GetAppsUseCase {}

class MockWatchMetrics extends Mock implements WatchMetrics {}

void main() {
  late MockGetDashboardInsights mockGetDashboardInsights;
  late MockGetAppsUseCase mockGetAppsUseCase;
  late MockWatchMetrics mockWatchMetrics;

  const appOne = AppModel(
    id: 'app-1',
    name: 'Demo App',
    apiKey: 'app_live_demo',
  );
  const appTwo = AppModel(
    id: 'app-2',
    name: 'Second App',
    apiKey: 'app_live_second',
  );

  final apps = [appOne];

  final insights = DashboardInsights(
    summary: [
      ScreenMetricModel(
        screen: 'home',
        avgRenderTime: 12.5,
        frameDrops: 2,
        avgApiLatency: 120.0,
        apiFailureCount: 0,
        crashCount: 0,
      ),
    ],
    analysis: AnalysisResult(
      severity: 'low',
      issues: [],
      recommendations: ['Looks good'],
    ),
  );

  DashboardLoaded loadedState({
    List<ScreenMetricModel> summary = const [],
    List<AppModel> stateApps = const [appOne],
    String selectedAppId = 'app-1',
    DashboardTab tab = DashboardTab.analytics,
    bool isLive = false,
  }) {
    return DashboardLoaded(
      summary: summary,
      analysis: AnalysisResult.empty(),
      apps: stateApps,
      selectedAppId: selectedAppId,
      tab: tab,
      isLive: isLive,
    );
  }

  DashboardBloc buildBloc() => DashboardBloc(
    mockGetDashboardInsights,
    mockGetAppsUseCase,
    mockWatchMetrics,
  );

  setUp(() {
    mockGetDashboardInsights = MockGetDashboardInsights();
    mockGetAppsUseCase = MockGetAppsUseCase();
    mockWatchMetrics = MockWatchMetrics();

    // Default: a stream that stays open and emits nothing. It must not
    // close, or the bloc would treat that as a dropped connection and emit
    // extra isLive transitions in tests that are not about the live feed.
    when(
      () => mockWatchMetrics(any()),
    ).thenAnswer((_) => StreamController<Map<String, dynamic>>().stream);
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardLoaded] when LoadDashboard succeeds',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => apps);
        when(
          () => mockGetDashboardInsights('app-1'),
        ).thenAnswer((_) async => insights);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDashboard()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>()
            .having((s) => s.summary, 'summary', insights.summary)
            .having((s) => s.analysis.severity, 'severity', 'low')
            .having((s) => s.selectedAppId, 'selectedAppId', 'app-1')
            .having((s) => s.apps, 'apps', apps),
        // Subscribing to the stream flips the live flag on.
        isA<DashboardLoaded>().having((s) => s.isLive, 'isLive', true),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardError] when no apps exist',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDashboard()),
      expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    );

    blocTest<DashboardBloc, DashboardState>(
      'RefreshDashboard updates data without re-emitting DashboardLoading',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => apps);
        when(
          () => mockGetDashboardInsights('app-1'),
        ).thenAnswer((_) async => insights);
      },
      build: buildBloc,
      seed: loadedState,
      act: (bloc) => bloc.add(RefreshDashboard()),
      expect: () => [
        isA<DashboardLoaded>().having(
          (s) => s.summary,
          'summary',
          insights.summary,
        ),
        isA<DashboardLoaded>().having((s) => s.isLive, 'isLive', true),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'ChangeDashboardTab updates the active tab while loaded',
      build: buildBloc,
      seed: () => loadedState(),
      act: (bloc) => bloc.add(ChangeDashboardTab(DashboardTab.apps)),
      expect: () => [
        isA<DashboardLoaded>().having((s) => s.tab, 'tab', DashboardTab.apps),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'a refresh keeps the selected app instead of snapping back to the first',
      setUp: () {
        when(
          () => mockGetAppsUseCase(),
        ).thenAnswer((_) async => [appOne, appTwo]);
        when(
          () => mockGetDashboardInsights('app-2'),
        ).thenAnswer((_) async => insights);
      },
      build: buildBloc,
      seed: () => loadedState(
        stateApps: const [appOne, appTwo],
        selectedAppId: 'app-2',
      ),
      act: (bloc) => bloc.add(RefreshDashboard()),
      expect: () => [
        isA<DashboardLoaded>().having(
          (s) => s.selectedAppId,
          'selectedAppId',
          'app-2',
        ),
        isA<DashboardLoaded>().having((s) => s.isLive, 'isLive', true),
      ],
      verify: (_) {
        // The previously selected app must be the one refetched.
        verify(() => mockGetDashboardInsights('app-2')).called(1);
        verifyNever(() => mockGetDashboardInsights('app-1'));
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'SelectApp switches apps and resubscribes the live stream',
      setUp: () {
        when(
          () => mockGetDashboardInsights('app-2'),
        ).thenAnswer((_) async => insights);
      },
      build: buildBloc,
      seed: () => loadedState(stateApps: const [appOne, appTwo], isLive: true),
      act: (bloc) => bloc.add(SelectApp('app-2')),
      expect: () => [
        // Live drops while the new app's stream is being established.
        isA<DashboardLoaded>()
            .having((s) => s.selectedAppId, 'selectedAppId', 'app-2')
            .having((s) => s.isLive, 'isLive', false),
        isA<DashboardLoaded>().having(
          (s) => s.summary,
          'summary',
          insights.summary,
        ),
        // ...and comes back once the new app's stream is connected.
        isA<DashboardLoaded>().having((s) => s.isLive, 'isLive', true),
      ],
      verify: (_) {
        verify(() => mockWatchMetrics('app-2')).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'marks itself live once the stream connects',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => apps);
        when(
          () => mockGetDashboardInsights('app-1'),
        ).thenAnswer((_) async => insights);
        // A stream that stays open, standing in for a live connection.
        when(
          () => mockWatchMetrics('app-1'),
        ).thenAnswer((_) => StreamController<Map<String, dynamic>>().stream);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDashboard()),
      skip: 2,
      expect: () => [
        isA<DashboardLoaded>().having((s) => s.isLive, 'isLive', true),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'stops claiming to be live when the stream drops',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => apps);
        when(
          () => mockGetDashboardInsights('app-1'),
        ).thenAnswer((_) async => insights);
        // Closes immediately, standing in for a dropped connection.
        when(
          () => mockWatchMetrics('app-1'),
        ).thenAnswer((_) => const Stream<Map<String, dynamic>>.empty());
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadDashboard()),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<DashboardLoaded>());
        expect((state as DashboardLoaded).isLive, isFalse);
      },
    );
  });
}
