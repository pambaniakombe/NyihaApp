/// Backend API base URL (Railway production).
///
/// Override for local API, e.g.:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:3000`

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://nyihaapp-production-4ca7.up.railway.app',
);

/// Path prefix for REST routes (see `backend/src/app.ts`).
const String kApiV1Prefix = '/api/v1';
