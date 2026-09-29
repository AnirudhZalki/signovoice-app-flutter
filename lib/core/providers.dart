import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/analytics_service.dart';
import 'services/api_client.dart';
import 'services/connectivity_service.dart';
import 'services/haptics_service.dart';
import 'services/permission_service.dart';
import 'services/storage.dart';
import 'services/tts_service.dart';
import 'services/usage_service.dart';

/// Injected at start-up (see bootstrap.dart). Tests override these.
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('keyValueStoreProvider must be overridden'),
);

final collectionStoreProvider = Provider<CollectionStore>((ref) => FileCollectionStore());

final secureStoreProvider = Provider<SecureStore>((ref) => FlutterSecureStore());

/// True only when Firebase.initializeApp succeeded (google-services.json present).
final firebaseAvailableProvider = Provider<bool>((ref) => false);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => PlusConnectivityService());

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final s = ref.watch(connectivityServiceProvider);
  yield await s.isOnline;
  yield* s.onlineStream;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return ref.watch(firebaseAvailableProvider) ? FirebaseAnalyticsService() : NoopAnalyticsService();
});

final permissionServiceProvider =
    Provider<PermissionService>((ref) => PermissionHandlerService());

final ttsServiceProvider = Provider<TtsService>((ref) {
  final s = FlutterTtsService();
  ref.onDispose(s.dispose);
  return s;
});

final hapticsServiceProvider = Provider<HapticsService>((ref) => HapticsService());

/// ID-token supplier for the API client. Null when signed out / no Firebase.
final authTokenProvider = Provider<TokenProvider>((ref) {
  final available = ref.watch(firebaseAvailableProvider);
  return () async {
    if (!available) return null;
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  };
});

final apiClientProvider =
    Provider<ApiClient>((ref) => ApiClient(tokenProvider: ref.watch(authTokenProvider)));

final usageServiceProvider = Provider<UsageService>(
  (ref) => UsageService(ref.watch(keyValueStoreProvider), ref.watch(clockProvider)),
);
