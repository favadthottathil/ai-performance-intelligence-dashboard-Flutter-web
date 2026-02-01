import 'package:ai_performance_intelligence_platfrom/core/di/injection.dart';
import 'package:ai_performance_intelligence_platfrom/features/apps/presentation/bloc/apps_bloc.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardEntry extends StatelessWidget {
  const DashboardEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (_) =>
              sl<DashboardBloc>()..add(LoadDashboard()),
        ),
        BlocProvider<AppsBloc>(
          create: (_) => sl<AppsBloc>(),
        ),
      ],
      child: const DashboardPage(),
    );
  }
}
