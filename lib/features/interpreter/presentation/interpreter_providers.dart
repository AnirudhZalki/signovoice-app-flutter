import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../data/http_interpreter_repository.dart';
import '../data/livekit_call_service.dart';
import '../data/order_checkout_runner.dart';
import '../data/livekit_token_service.dart';
import '../domain/call_service.dart';
import '../domain/interpreter_models.dart';
import '../domain/interpreter_repository.dart';

final interpreterRepositoryProvider =
    Provider<InterpreterRepository>((ref) => HttpInterpreterRepository(ref.watch(apiClientProvider)));

/// Factory so tests can inject a fake call transport.
final callServiceFactoryProvider = Provider<CallService Function()>((ref) => () => LiveKitCallService());

/// Interpreter availability, refreshed every 15 s while something is listening
/// (the poll stops automatically when the screen closes).
final interpretersProvider = StreamProvider.autoDispose.family<List<Interpreter>, String?>((ref, language) async* {
  final repo = ref.watch(interpreterRepositoryProvider);
  while (true) {
    yield await repo.list(language: language);
    await Future<void>.delayed(const Duration(seconds: 15));
  }
});

final liveKitTokenServiceProvider = Provider<LiveKitTokenService>(
    (ref) => LiveKitTokenService(authToken: ref.read(authTokenProvider)));

/// The signed-in person's interpreter profile; errors (no backend, offline) read as "not an interpreter".
final interpreterMeProvider = FutureProvider.autoDispose<InterpreterMe>((ref) async {
  try {
    return await ref.watch(interpreterRepositoryProvider).me();
  } catch (_) {
    return const InterpreterMe(approved: false);
  }
});

/// The interpreter's queue, refreshed every 4 s while the desk is open.
final interpreterQueueProvider = StreamProvider.autoDispose<List<IncomingRequest>>((ref) async* {
  final repo = ref.watch(interpreterRepositoryProvider);
  while (true) {
    yield await repo.queue();
    await Future<void>.delayed(const Duration(seconds: 4));
  }
});

/// LiveKit server URL used when a session doesn't carry one (overridden in tests).
final livekitUrlProvider = Provider<String>((_) => AppConfig.livekitUrl);

final orderCheckoutRunnerProvider = Provider<OrderCheckoutRunner>((ref) => RazorpayCheckoutRunner());
