import 'package:ai_performance_intelligence_platform/features/apps/data/models/app_model.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable view of everything the switcher renders, so the surrounding
/// [BlocSelector] only rebuilds when the app list or selection changes —
/// not on every metrics refresh.
@immutable
class _SwitcherData {
  const _SwitcherData(this.apps, this.selectedAppId);

  final List<AppModel> apps;
  final String? selectedAppId;

  @override
  bool operator ==(Object other) =>
      other is _SwitcherData &&
      other.selectedAppId == selectedAppId &&
      _sameApps(other.apps, apps);

  static bool _sameApps(List<AppModel> a, List<AppModel> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(selectedAppId, Object.hashAll(apps));
}

/// Lets the user choose which application the dashboard is showing.
///
/// Without this the dashboard always displayed the first app the API
/// returned, leaving every other app the user owned unreachable.
class AppSwitcher extends StatelessWidget {
  const AppSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DashboardBloc, DashboardState, _SwitcherData>(
      selector: (state) => state is DashboardLoaded
          ? _SwitcherData(state.apps, state.selectedAppId)
          : const _SwitcherData(<AppModel>[], null),
      builder: (context, data) {
        // A single app needs no switcher.
        if (data.apps.length < 2) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: data.selectedAppId,
              isDense: true,
              dropdownColor: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(
                Icons.expand_more_rounded,
                color: Colors.white70,
                size: 18,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: [
                for (final app in data.apps)
                  DropdownMenuItem<String>(
                    value: app.id,
                    child: Text(
                      app.name.isEmpty ? 'Untitled app' : app.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (appId) {
                if (appId == null || appId == data.selectedAppId) return;
                context.read<DashboardBloc>().add(SelectApp(appId));
              },
            ),
          ),
        );
      },
    );
  }
}
