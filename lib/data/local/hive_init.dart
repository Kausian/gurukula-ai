import 'app_storage.dart';

/// Initializes Hive and opens every box the app needs.
///
/// Must complete before [runApp] so repositories can read their boxes
/// synchronously. All study data lives here, on the device, only. As of
/// v1.22.0 the study-data boxes are encrypted at rest where possible; see
/// [AppStorage] for the key handling and the safe migration path.
Future<void> initHive() => AppStorage.init();
