abstract class AppsEvent {}

class CreateAppRequested extends AppsEvent {
  final String name;
  CreateAppRequested(this.name);
}

/// Issues a new API key for an existing app, invalidating the old one.
///
/// Deliberately separate from [CreateAppRequested]: rotation breaks every
/// SDK client still shipping the previous key, so it must never happen as a
/// side effect of creating an app.
class RotateApiKeyRequested extends AppsEvent {
  final String appId;
  RotateApiKeyRequested(this.appId);
}

class LoadApps extends AppsEvent {}
