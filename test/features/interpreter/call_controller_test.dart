import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/core/providers.dart';
import 'package:signovoice/core/services/analytics_service.dart';
import 'package:signovoice/core/services/api_client.dart';
import 'package:signovoice/core/services/permission_service.dart';
import 'package:signovoice/core/services/storage.dart';
import 'package:signovoice/features/auth/domain/app_user.dart';
import 'package:signovoice/features/auth/presentation/auth_controller.dart';
import 'package:signovoice/features/interpreter/domain/call_service.dart';
import 'package:signovoice/features/interpreter/domain/interpreter_models.dart';
import 'package:signovoice/features/interpreter/domain/interpreter_repository.dart';
import 'package:signovoice/features/interpreter/presentation/call_controller.dart';
import 'package:signovoice/features/interpreter/presentation/interpreter_providers.dart';

// ---- test-only fakes ----
class _Auth extends AuthController {
  _Auth(this.signedIn);
  final bool signedIn;
  @override
  AuthState build() => signedIn ? const AuthState(AuthStatus.authenticated, AppUser(uid: 'u1')) : const AuthState(AuthStatus.guest, AppUser.guest);
}

class _Perms implements PermissionService {
  _Perms(this.result);
  final PermissionState result;
  @override
  Future<PermissionState> status(AppPermission p) async => result;
  @override
  Future<PermissionState> request(AppPermission p) async => result;
  @override
  Future<void> openSettings() async {}
}

class _Repo implements InterpreterRepository {
  _Repo(this.responses);
  final List<CallRequestState> responses; // first = request result, rest = polls
  int polls = 0;
  bool cancelled = false;
  @override
  Future<List<Interpreter>> list({String? language}) async => const [];
  @override
  Future<CallRequestState> requestInterpreter({required CallMode mode, required String language, String? interpreterId, String? note}) async =>
      responses.first;
  @override
  Future<CallRequestState> requestStatus(String requestId) async => responses[(1 + polls++).clamp(0, responses.length - 1)];
  @override
  Future<void> cancelRequest(String requestId) async => cancelled = true;
  @override
  Future<void> submitFeedback({required String callId, required int rating, String? comment}) async {}
  @override
  Future<void> reportIssue({required String callId, required IssueCategory category, String? details}) async {}
  @override
  Future<InterpreterMe> me() async => const InterpreterMe(approved: false);
  @override
  Future<void> setAvailability({required bool available}) async {}
  @override
  Future<List<IncomingRequest>> queue() async => const [];
  @override
  Future<CallSession> accept(String requestId) async => throw UnimplementedError();
  @override
  Future<void> endCall(String callId) async {}
}

class _Call implements CallService {
  final link = StreamController<LinkState>.broadcast();
  final chat = StreamController<CallChatMessage>.broadcast();
  final ended = StreamController<void>.broadcast();
  final change = StreamController<void>.broadcast();
  String? url;
  String? token;
  bool mic = true;
  bool disconnected = false;
  @override
  Stream<LinkState> get linkState => link.stream;
  @override
  Stream<CallChatMessage> get chatMessages => chat.stream;
  @override
  Stream<void> get remoteEnded => ended.stream;
  @override
  Stream<void> get changes => change.stream;
  @override
  bool get isMicEnabled => mic;
  @override
  bool get isCameraEnabled => true;
  @override
  bool get hasRemoteVideo => false;
  @override
  Future<void> connect({required String url, required String token, required bool video}) async {
    this.url = url;
    this.token = token;
    link.add(LinkState.connecting);
    link.add(LinkState.connected);
  }

  @override
  Future<void> setMicEnabled(bool enabled) async => mic = enabled;
  @override
  Future<void> setCameraEnabled(bool enabled) async {}
  @override
  Future<void> switchCamera() async {}
  @override
  Future<void> sendChat(String text) async =>
      chat.add(CallChatMessage(id: '1', fromMe: true, text: text, timestamp: DateTime(2026)));
  @override
  Future<void> disconnect() async => disconnected = true;
  @override
  Widget? remoteView() => null;
  @override
  Widget? localView() => null;
  @override
  Future<void> dispose() async {}
}

const _session = CallSession(callId: 'call1', token: 'tok', roomName: 'room', url: 'wss://lk.test', interpreterName: 'Asha');
const _accepted = CallRequestState(requestId: 'r1', status: RequestStatus.accepted, session: _session);
const _waiting = CallRequestState(requestId: 'r1', status: RequestStatus.waiting, queuePosition: 2);

ProviderContainer _make({
  bool signedIn = true,
  bool configured = true,
  PermissionState perm = PermissionState.granted,
  required _Repo repo,
  _Call? call,
}) {
  final c = ProviderContainer(overrides: [
    keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
    authControllerProvider.overrideWith(() => _Auth(signedIn)),
    apiClientProvider.overrideWithValue(ApiClient(tokenProvider: () async => null, baseUrl: configured ? 'https://api.test' : '')),
    isOnlineProvider.overrideWith((ref) => Stream.value(true)),
    permissionServiceProvider.overrideWithValue(_Perms(perm)),
    analyticsServiceProvider.overrideWithValue(NoopAnalyticsService()),
    interpreterRepositoryProvider.overrideWithValue(repo),
    callServiceFactoryProvider.overrideWithValue(() => call ?? _Call()),
    callPollIntervalProvider.overrideWithValue(const Duration(milliseconds: 30)),
  ]);
  addTearDown(c.dispose);
  c.listen(callControllerProvider, (_, _) {});
  return c;
}

Future<void> _until(bool Function() cond) async {
  final end = DateTime.now().add(const Duration(seconds: 5));
  while (!cond()) {
    if (DateTime.now().isAfter(end)) fail('timed out');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  test('guests cannot request an interpreter (unauthorized)', () async {
    final c = _make(signedIn: false, repo: _Repo([_accepted]));
    await c.read(callControllerProvider.notifier).request(mode: CallMode.video, language: 'en');
    expect(c.read(callControllerProvider).phase, CallPhase.failed);
    expect(c.read(callControllerProvider).failure?.type, FailureType.unauthorized);
  });

  test('interpreter service reports notConfigured without a backend', () async {
    final c = _make(configured: false, repo: _Repo([_accepted]));
    await c.read(callControllerProvider.notifier).request(mode: CallMode.video, language: 'en');
    expect(c.read(callControllerProvider).failure?.type, FailureType.notConfigured);
  });

  test('microphone denied stops before any request is sent', () async {
    final repo = _Repo([_accepted]);
    final c = _make(perm: PermissionState.denied, repo: repo);
    await c.read(callControllerProvider.notifier).request(mode: CallMode.audio, language: 'en');
    expect(c.read(callControllerProvider).failure?.type, FailureType.permissionDenied);
    final c2 = _make(perm: PermissionState.permanentlyDenied, repo: repo);
    await c2.read(callControllerProvider.notifier).request(mode: CallMode.audio, language: 'en');
    expect(c2.read(callControllerProvider).failure?.type, FailureType.permissionPermanentlyDenied);
  });

  test('accepted request connects, tracks state, chats, mutes and ends with a callId for feedback', () async {
    final call = _Call();
    final c = _make(repo: _Repo([_accepted]), call: call);
    final ctrl = c.read(callControllerProvider.notifier);
    await ctrl.request(mode: CallMode.video, language: 'hi');
    await _until(() => c.read(callControllerProvider).phase == CallPhase.connected);

    expect(call.url, 'wss://lk.test');
    expect(call.token, 'tok');
    expect(c.read(callControllerProvider).interpreterName, 'Asha');

    await ctrl.toggleMic();
    expect(call.mic, isFalse);
    expect(c.read(callControllerProvider).micOn, isFalse);

    ctrl.setChatOpen(false);
    await ctrl.sendChat('hello');
    await _until(() => c.read(callControllerProvider).messages.isNotEmpty);
    expect(c.read(callControllerProvider).messages.single.text, 'hello');

    call.link.add(LinkState.reconnecting);
    await _until(() => c.read(callControllerProvider).phase == CallPhase.reconnecting);
    call.link.add(LinkState.connected);
    await _until(() => c.read(callControllerProvider).phase == CallPhase.connected);

    await ctrl.end();
    expect(c.read(callControllerProvider).phase, CallPhase.ended);
    expect(c.read(callControllerProvider).callId, 'call1');
    expect(call.disconnected, isTrue);
  });

  test('waiting request is polled until an interpreter accepts', () async {
    final repo = _Repo([_waiting, _waiting, _accepted]);
    final c = _make(repo: repo);
    await c.read(callControllerProvider.notifier).request(mode: CallMode.video, language: 'en');
    expect(c.read(callControllerProvider).phase, CallPhase.waiting);
    expect(c.read(callControllerProvider).queuePosition, 2);
    await _until(() => c.read(callControllerProvider).phase == CallPhase.connected);
  });

  test('declined request ends with a tailored reason, not a crash', () async {
    final repo = _Repo([_waiting, const CallRequestState(requestId: 'r1', status: RequestStatus.declined)]);
    final c = _make(repo: repo);
    await c.read(callControllerProvider.notifier).request(mode: CallMode.video, language: 'en');
    await _until(() => c.read(callControllerProvider).phase == CallPhase.failed);
    expect(c.read(callControllerProvider).failureReason, RequestStatus.declined);
  });

  test('cancelling a waiting request tells the backend and resets', () async {
    final repo = _Repo([_waiting, _waiting]);
    final c = _make(repo: repo);
    final ctrl = c.read(callControllerProvider.notifier);
    await ctrl.request(mode: CallMode.video, language: 'en');
    await ctrl.cancelRequest();
    expect(repo.cancelled, isTrue);
    expect(c.read(callControllerProvider).phase, CallPhase.idle);
  });

  test('missing LiveKit URL is reported as notConfigured', () async {
    final noUrl = const CallRequestState(
        requestId: 'r1', status: RequestStatus.accepted, session: CallSession(callId: 'c', token: 't', roomName: 'r'));
    final c = _make(repo: _Repo([noUrl]));
    await c.read(callControllerProvider.notifier).request(mode: CallMode.video, language: 'en');
    await _until(() => c.read(callControllerProvider).phase == CallPhase.failed);
    expect(c.read(callControllerProvider).failure?.type, FailureType.notConfigured);
  });
}
