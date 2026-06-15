# AI Performance Intelligence — Dashboard

A Flutter Web dashboard for the [AI Performance Intelligence backend](https://github.com/favadthottathil/ai-performance-intelligence-backend),
which ingests Flutter app performance telemetry collected by
[flutter_metrics_sdk](https://pub.dev/packages/flutter_metrics_sdk).

The dashboard signs in with a JWT, lists the apps registered under that
account, and shows live render-time, frame-drop, API-latency and crash
charts per screen, alongside AI-generated insights and a severity score.

## Features

- Email/password authentication (signup, login, persisted JWT)
- App management (create an app, view its API key)
- Per-screen analytics: average render time, frame drops, API latency, crash count
- AI-generated issues, recommendations and severity (low / medium / high) via the backend's Gemini integration
- Live dashboard — automatically refreshes in the background every 15s so new
  metrics show up without a manual reload (a manual refresh button is also available)
- Responsive layout: sidebar navigation on desktop, bottom navigation + drawer on mobile

## Tech Stack

- Flutter Web, Dart
- flutter_bloc (state management), go_router (routing)
- get_it + injectable (dependency injection)
- dio (HTTP client), flutter_secure_storage (token storage)
- fl_chart (charts)
- bloc_test + mocktail (testing)

## Getting Started

```bash
flutter pub get

# Point the app at your backend (defaults to the deployed Render instance)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

The backend setup (database, env vars, migrations) is documented in the
[backend README](https://github.com/favadthottathil/ai-performance-intelligence-backend).

## Building for the web

```bash
flutter build web --release --dart-define=API_BASE_URL=https://your-backend
```

## Testing

```bash
flutter test
```

Tests cover `DashboardBloc` (loading, background refresh, error and tab
state transitions) and the analytics page's loading/empty/loaded states,
using `bloc_test` and `mocktail` — no live backend required.
