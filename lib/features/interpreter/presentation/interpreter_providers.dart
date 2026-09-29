import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/http_interpreter_repository.dart';
import '../data/livekit_call_service.dart';
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
