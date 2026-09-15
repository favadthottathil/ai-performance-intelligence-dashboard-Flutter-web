import 'package:ai_performance_intelligence_platform/features/dashboard/presentation/bloc/dashbaord_tab.dart';
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class ChangeDashboardTab extends DashboardEvent {
  final DashboardTab tab;
  ChangeDashboardTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Switches the dashboard to a different application, re-subscribing the
/// live stream to it.
class SelectApp extends DashboardEvent {
  final String appId;
  SelectApp(this.appId);

  @override
  List<Object?> get props => [appId];
}

/// Emitted internally when the live stream delivers a metric, so the
/// dashboard refreshes in response to real ingestion instead of a timer.
class LiveMetricReceived extends DashboardEvent {
  LiveMetricReceived();
}

/// Emitted internally when the live connection goes up or down, so the UI
/// can stop claiming to be live when it is not.
class LiveConnectionChanged extends DashboardEvent {
  final bool connected;
  LiveConnectionChanged(this.connected);

  @override
  List<Object?> get props => [connected];
}
