import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/permission_service.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/call_service.dart';
import '../domain/interpreter_models.dart';
import 'interpreter_providers.dart';

class CallState {
  const CallState({
    this.phase = CallPhase.idle,
    this.mode = CallMode.video,
    this.failure,
    this.failureReason,
    this.callId,
    this.interpreterName,
    this.queuePosition,
    this.elapsed = Duration.zero,
    this.micOn = true,
    this.camOn = true,
    this.remoteVideo = false,
    this.messages = const [],
    this.unread = 0,
  });

  final CallPhase phase;
  final CallMode mode;
  final Failure? failure;

  /// Declined / expired requests are not "failures" of the system; UI shows tailored text.
  final RequestStatus? failureReason;
  final String? callId;
  final String? interpreterName;
  final int? queuePosition;
  final Duration elapsed;
  final bool micOn;
  final bool camOn;
  final bool remoteVideo;
  final List<CallChatMessage> messages;
  final int unread;

  bool get inCall => phase == CallPhase.connected || phase == CallPhase.reconnecting;

  CallState copyWith({
    CallPhase? phase,
    CallMode? mode,
    Failure? failure,
    bool clearFailure = false,
    RequestStatus? failureReason,
    String? callId,
    String? interpreterName,
    int? queuePosition,
    Duration? elapsed,
    bool? micOn,
    bool? camOn,
    bool? remoteVideo,
    List<CallChatMessage>? messages,
    int? unread,
  }) =>
      CallState(
        phase: phase ?? this.phase,
        mode: mode ?? this.mode,
        failure: clearFailure ? null : (failure ?? this.failure),
        failureReason: clearFailure ? null : (failureReason ?? this.failureReason),
        callId: callId ?? this.callId,
        interpreterName: interpreterName ?? this.interpreterName,
        queuePosition: queuePosition ?? this.queuePosition,
        elapsed: elapsed ?? this.elapsed,
        micOn: micOn ?? this.micOn,
        camOn: camOn ?? this.camOn,
        remoteVideo: remoteVideo ?? this.remoteVideo,
        messages: messages ?? this.messages,
        unread: unread ?? this.unread,
      );
}

/// How often a waiting request is checked (overridden in tests).
final callPollIntervalProvider = Provider<Duration>((ref) => const Duration(seconds: 3));

class CallController extends Notifier<CallState> {
  CallService? _service;
  Timer? _poll;
  Timer? _clock;
  StreamSubscription<LinkState>? _linkSub;
  StreamSubscription<CallChatMessage>? _chatSub;
  StreamSubscription<void>? _endedSub;
  StreamSubscription<void>? _changeSub;
  String? _requestId;
  bool _polling = false;
  bool _disposed = false;
  DateTime? _connectedAt;
  bool _chatOpen = false;

  static const requestTimeout = Duration(minutes: 3);

  CallService? get service => _service;

  @override
  CallState build() {
    ref.onDispose(() {
      _disposed = true;
      _cancelTimers();
      _service?.dispose();
    });
    return const CallState();
  }

  void _fail(Failure f, {RequestStatus? reason}) {
    _cancelTimers();
    if (!_disposed) state = state.copyWith(phase: CallPhase.failed, failure: f, failureReason: reason);
  }

  /// Debug-only test call: joins the LiveKit room the dev token was issued for (no backend needed).
  Future<void> joinDevRoom(CallMode mode) async {
    if (!AppConfig.hasDevRoom || state.phase == CallPhase.requesting || state.inCall) return;
    state = CallState(phase: CallPhase.requesting, mode: mode, camOn: mode == CallMode.video);
    final perms = ref.read(permissionServiceProvider);
    if (await perms.request(AppPermission.microphone) != PermissionState.granted) {
      return _fail(const Failure(FailureType.permissionDenied));
    }
    if (mode == CallMode.video && await perms.request(AppPermission.camera) != PermissionState.granted) {
      return _fail(const Failure(FailureType.permissionDenied));
    }
    await _connect(const CallSession(callId: 'dev', token: AppConfig.livekitDevToken, roomName: 'dev', url: AppConfig.livekitUrl));
  }

  Future<void> request({required CallMode mode, required String language, String? interpreterId, String? note}) async {
    if (state.phase == CallPhase.requesting || state.phase == CallPhase.waiting || state.inCall) return;
    state = CallState(phase: CallPhase.requesting, mode: mode, camOn: mode == CallMode.video);
    if (!ref.read(authControllerProvider).isSignedIn) return _fail(const Failure(FailureType.unauthorized));
    final api = ref.read(apiClientProvider);
    if (!api.isConfigured) return _fail(const Failure(FailureType.notConfigured, debugDetail: 'API_BASE_URL'));
    if (!(ref.read(isOnlineProvider).value ?? true)) return _fail(const Failure(FailureType.offline));

    // Just-in-time permissions: microphone always, camera only for video calls.
    final perms = ref.read(permissionServiceProvider);
    final mic = await perms.request(AppPermission.microphone);
    if (mic != PermissionState.granted) {
      return _fail(Failure(mic == PermissionState.permanentlyDenied ? FailureType.permissionPermanentlyDenied : FailureType.permissionDenied));
    }
    if (mode == CallMode.video) {
      final cam = await perms.request(AppPermission.camera);
      if (cam != PermissionState.granted) {
        return _fail(Failure(cam == PermissionState.permanentlyDenied ? FailureType.permissionPermanentlyDenied : FailureType.permissionDenied));
      }
    }

    try {
      final req = await ref
          .read(interpreterRepositoryProvider)
          .requestInterpreter(mode: mode, language: language, interpreterId: interpreterId, note: note);
      _requestId = req.requestId;
      ref.read(analyticsServiceProvider).log(AnalyticsEvents.interpreterRequest, {'mode': mode.name});
      if (_disposed) return;
      state = state.copyWith(phase: CallPhase.waiting, queuePosition: req.queuePosition);
      _startPolling();
      if (req.status == RequestStatus.accepted && req.session != null) await _connect(req.session!);
    } catch (e) {
      _fail(toFailure(e));
    }
  }

  void _startPolling() {
    final started = DateTime.now();
    _poll = Timer.periodic(ref.read(callPollIntervalProvider), (_) async {
      if (_polling || _requestId == null || state.phase != CallPhase.waiting) return;
      if (DateTime.now().difference(started) > requestTimeout) {
        await cancelRequest(silent: true);
        return _fail(const Failure(FailureType.timeout), reason: RequestStatus.expired);
      }
      _polling = true;
      try {
        final s = await ref.read(interpreterRepositoryProvider).requestStatus(_requestId!);
        if (_disposed || state.phase != CallPhase.waiting) return;
        switch (s.status) {
          case RequestStatus.waiting:
            state = state.copyWith(queuePosition: s.queuePosition);
          case RequestStatus.accepted:
            if (s.session != null) {
              _poll?.cancel();
              await _connect(s.session!);
            }
          case RequestStatus.declined:
          case RequestStatus.expired:
          case RequestStatus.cancelled:
            _fail(const Failure(FailureType.unknown), reason: s.status);
        }
      } catch (e) {
        final f = toFailure(e);
        // Transient network errors keep polling; anything else ends the request.
        if (!f.isRetryable) _fail(f);
      } finally {
        _polling = false;
      }
    });
  }

  Future<void> _connect(CallSession session) async {
    _poll?.cancel();
    final url = (session.url != null && session.url!.startsWith('wss://')) ? session.url! : AppConfig.livekitUrl;
    if (!url.startsWith('wss://')) return _fail(const Failure(FailureType.notConfigured, debugDetail: 'LIVEKIT_URL'));
    state = state.copyWith(phase: CallPhase.connecting, callId: session.callId, interpreterName: session.interpreterName);
    final service = ref.read(callServiceFactoryProvider)();
    _service = service;
    _linkSub = service.linkState.listen(_onLink);
    _chatSub = service.chatMessages.listen((m) {
      state = state.copyWith(messages: [...state.messages, m], unread: (m.fromMe || _chatOpen) ? state.unread : state.unread + 1);
    });
    _endedSub = service.remoteEnded.listen((_) => _onRemoteEnded());
    _changeSub = service.changes.listen((_) {
      if (_disposed) return;
      state = state.copyWith(remoteVideo: service.hasRemoteVideo, micOn: service.isMicEnabled, camOn: service.isCameraEnabled);
    });
    try {
      await service.connect(url: url, token: session.token, video: state.mode == CallMode.video);
    } catch (e) {
      _fail(toFailure(e));
    }
  }

  void _onLink(LinkState s) {
    if (_disposed) return;
    switch (s) {
      case LinkState.connected:
        _connectedAt ??= DateTime.now();
        _clock ??= Timer.periodic(const Duration(seconds: 1), (_) {
          if (!_disposed && _connectedAt != null) state = state.copyWith(elapsed: DateTime.now().difference(_connectedAt!));
        });
        state = state.copyWith(phase: CallPhase.connected, micOn: _service?.isMicEnabled, camOn: _service?.isCameraEnabled);
      case LinkState.reconnecting:
        state = state.copyWith(phase: CallPhase.reconnecting);
      case LinkState.connecting:
        if (state.phase != CallPhase.connected) state = state.copyWith(phase: CallPhase.connecting);
      case LinkState.disconnected:
        break; // handled via remoteEnded / explicit end
    }
  }

  void _onRemoteEnded() {
    if (state.phase == CallPhase.ended || state.phase == CallPhase.idle) return;
    _finishCall();
  }

  Future<void> toggleMic() async {
    final s = _service;
    if (s == null) return;
    await s.setMicEnabled(!s.isMicEnabled);
    state = state.copyWith(micOn: s.isMicEnabled);
  }

  Future<void> toggleCamera() async {
    final s = _service;
    if (s == null) return;
    await s.setCameraEnabled(!s.isCameraEnabled);
    state = state.copyWith(camOn: s.isCameraEnabled);
  }

  Future<void> switchCamera() async => _service?.switchCamera();

  Future<void> sendChat(String text) async {
    try {
      await _service?.sendChat(text);
    } catch (_) {/* keep UI responsive; message simply isn't added */}
  }

  void setChatOpen(bool open) {
    _chatOpen = open;
    if (open && state.unread != 0) state = state.copyWith(unread: 0);
  }

  Future<void> cancelRequest({bool silent = false}) async {
    final id = _requestId;
    _poll?.cancel();
    if (id != null) {
      try {
        await ref.read(interpreterRepositoryProvider).cancelRequest(id);
      } catch (_) {}
    }
    _requestId = null;
    if (!silent && !_disposed) state = const CallState();
  }

  Future<void> end() async {
    if (state.phase == CallPhase.waiting || state.phase == CallPhase.requesting) return cancelRequest();
    await _finishCall();
  }

  Future<void> _finishCall() async {
    _cancelTimers();
    final s = _service;
    _service = null;
    await s?.disconnect();
    unawaited(s?.dispose());
    if (!_disposed) state = state.copyWith(phase: CallPhase.ended, remoteVideo: false);
  }

  /// Clears a finished/failed call so a new one can start.
  void reset() {
    _cancelTimers();
    _requestId = null;
    _connectedAt = null;
    state = const CallState();
  }

  void _cancelTimers() {
    _poll?.cancel();
    _clock?.cancel();
    _poll = _clock = null;
    _linkSub?.cancel();
    _chatSub?.cancel();
    _endedSub?.cancel();
    _changeSub?.cancel();
    _linkSub = _chatSub = _endedSub = _changeSub = null;
  }
}

/// Not auto-disposed: a call must survive navigating between call/chat/feedback screens.
final callControllerProvider = NotifierProvider<CallController, CallState>(CallController.new);
