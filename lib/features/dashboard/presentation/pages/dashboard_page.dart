import 'package:ai_performance_intelligence_platfrom/core/di/injection.dart';
import 'package:ai_performance_intelligence_platfrom/core/storage/token_storage.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platfrom/features/dashboard/presentation/widgets/dashboard_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  final Widget child;
  const DashboardPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Performance Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await sl<TokenStorage>().clear();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSidebar(),
          Flexible(child: child),
        ],
      ),
    );
  }
}
