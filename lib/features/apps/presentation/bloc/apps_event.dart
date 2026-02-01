abstract class AppsEvent {}

class CreateAppRequested extends AppsEvent {
  final String name;
  CreateAppRequested(this.name);
}

class LoadApps extends AppsEvent {}
