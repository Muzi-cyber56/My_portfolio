# Sentinel Flutter app
Run `flutter pub get`, then `flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:5240`.
The API must already be running. Native Android emulators reach the host through 10.0.2.2; pass that address with API_BASE_URL. Use HTTPS for deployed builds.

The black/blue/white theme lives in lib/config/app_config.dart. All requested screens are present. Shared OsintToolScreen and EvidenceScreen reduce duplicated form logic. Models/services use the real REST API; dashboard counts are derived from the authenticated user's cases.

Use `flutter analyze`, `flutter test` and the commands in the root README. See the root documentation for actual provider coverage, OCR configuration and PDF limitations.
