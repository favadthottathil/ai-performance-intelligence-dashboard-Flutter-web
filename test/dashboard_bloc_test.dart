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

void main() {
  late MockGetDashboardInsights mockGetDashboardInsights;
  late MockGetAppsUseCase mockGetAppsUseCase;

  final apps = [AppModel(id: 'app-1', name: 'Demo App', apiKey: 'app_live_demo')];

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

  setUp(() {
    mockGetDashboardInsights = MockGetDashboardInsights();
    mockGetAppsUseCase = MockGetAppsUseCase();
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardLoaded] when LoadDashboard succeeds',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => apps);
        when(() => mockGetDashboardInsights('app-1'))
            .thenAnswer((_) async => insights);
      },
      build: () => DashboardBloc(mockGetDashboardInsights, mockGetAppsUseCase),
      act: (bloc) => bloc.add(LoadDashboard()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>()
            .having((s) => s.summary, 'summary', insights.summary)
            .having((s) => s.analysis.severity, 'severity', 'low'),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardError] when no apps exist',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => []);
      },
      build: () => DashboardBloc(mockGetDashboardInsights, mockGetAppsUseCase),
      act: (bloc) => bloc.add(LoadDashboard()),
      expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    );

    blocTest<DashboardBloc, DashboardState>(
      'RefreshDashboard updates data without re-emitting DashboardLoading',
      setUp: () {
        when(() => mockGetAppsUseCase()).thenAnswer((_) async => apps);
        when(() => mockGetDashboardInsights('app-1'))
            .thenAnswer((_) async => insights);
      },
      build: () => DashboardBloc(mockGetDashboardInsights, mockGetAppsUseCase),
      seed: () => DashboardLoaded(summary: const [], analysis: AnalysisResult.empty()),
      act: (bloc) => bloc.add(RefreshDashboard()),
      expect: () => [
        isA<DashboardLoaded>()
            .having((s) => s.summary, 'summary', insights.summary),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'ChangeDashboardTab updates the active tab while loaded',
      build: () => DashboardBloc(mockGetDashboardInsights, mockGetAppsUseCase),
      seed: () => DashboardLoaded(
        summary: const [],
        analysis: AnalysisResult.empty(),
        tab: DashboardTab.analytics,
      ),
      act: (bloc) => bloc.add(ChangeDashboardTab(DashboardTab.apps)),
      expect: () => [
        isA<DashboardLoaded>().having((s) => s.tab, 'tab', DashboardTab.apps),
      ],
    );
  });
}
