import '../../data/models/app_model.dart';

abstract class AppsState {}

class AppsInitial extends AppsState {}

class AppsLoading extends AppsState {}

class AppCreated extends AppsState {
  final AppModel app;
  AppCreated(this.app);
}

class AppsLoaded extends AppsState {
  final List<AppModel> apps;
  AppsLoaded(this.apps);
}

class AppsError extends AppsState {
  final String message;
  AppsError(this.message);
}
