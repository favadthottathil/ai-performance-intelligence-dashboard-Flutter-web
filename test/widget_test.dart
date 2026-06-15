import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/analysis_result.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/data/models/screen_metric_model.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/pages/analytics_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

Widget _wrap(DashboardBloc bloc) {
  return MaterialApp(
    home: BlocProvider<DashboardBloc>.value(
      value: bloc,
      child: const AnalyticsPage(),
    ),
  );
}

void main() {
  late MockDashboardBloc bloc;

  setUp(() {
    bloc = MockDashboardBloc();
  });

  testWidgets('shows a loading indicator while the dashboard is loading', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream<DashboardState>.empty(),
      initialState: DashboardLoading(),
    );

    await tester.pumpWidget(_wrap(bloc));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty state when no metrics have been collected', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream<DashboardState>.empty(),
      initialState: DashboardLoaded(
        summary: const [],
        analysis: AnalysisResult.empty(),
      ),
    );

    await tester.pumpWidget(_wrap(bloc));

    expect(find.text('Dashboard is Empty'), findsOneWidget);
  });

  testWidgets('renders charts and severity once metrics are loaded', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream<DashboardState>.empty(),
      initialState: DashboardLoaded(
        summary: [
          ScreenMetricModel(
            screen: 'home',
            avgRenderTime: 14,
            frameDrops: 3,
            avgApiLatency: 120,
            apiFailureCount: 0,
            crashCount: 0,
          ),
        ],
        analysis: AnalysisResult(
          severity: 'medium',
          issues: ['home: frame drops above budget'],
          recommendations: ['Avoid rebuilding large widget trees'],
        ),
      ),
    );

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.text('MEDIUM'), findsOneWidget);
    expect(find.text('home: frame drops above budget'), findsOneWidget);
    expect(find.text('Avoid rebuilding large widget trees'), findsOneWidget);
  });
}
