import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../core/errors/failure.dart';
import '../domain/call_service.dart';
import '../domain/interpreter_models.dart';

/// LiveKit-backed [CallService]. The access token is minted by the backend;
/// no API key/secret exists in the app.
class LiveKitCallService implements CallService {
  LiveKitCallService() {
    _room = Room(roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true));
    _room.addListener(_notify);
    _listener = _room.createListener()
      ..on<RoomReconnectingEvent>((_) => _link.add(LinkState.reconnecting))
      ..on<RoomReconnectedEvent>((_) => _link.add(LinkState.connected))
      ..on<RoomDisconnectedEvent>((_) {
        _link.add(LinkState.disconnected);
        _remoteEnded.add(null);
      })
      ..on<ParticipantDisconnectedEvent>((_) {
        if (_room.remoteParticipants.isEmpty) _remoteEnded.add(null);
      })
      ..on<DataReceivedEvent>(_onData);
  }

  late final Room _room;
  late final EventsListener<RoomEvent> _listener;
  final _link = StreamController<LinkState>.broadcast();
  final _chat = StreamController<CallChatMessage>.broadcast();
  final _remoteEnded = StreamController<void>.broadcast();
  final _changes = StreamController<void>.broadcast();
  bool _front = true;
  bool _disposed = false;

  void _notify() {
    if (!_disposed && !_changes.isClosed) _changes.add(null);
  }

  void _onData(DataReceivedEvent e) {
    if (e.topic != 'chat') return;
    try {
      final m = jsonDecode(utf8.decode(e.data)) as Map<String, dynamic>;
      _chat.add(CallChatMessage(
        id: '${m['id'] ?? DateTime.now().microsecondsSinceEpoch}',
        fromMe: false,
        text: (m['text'] as String? ?? '').trim(),
        timestamp: DateTime.now(),
      ));
    } catch (_) {/* ignore malformed chat packets */}
  }

  @override
  Stream<LinkState> get linkState => _link.stream;
  @override
  Stream<CallChatMessage> get chatMessages => _chat.stream;
  @override
  Stream<void> get remoteEnded => _remoteEnded.stream;
  @override
  Stream<void> get changes => _changes.stream;

  @override
  bool get isMicEnabled => _room.localParticipant?.isMicrophoneEnabled() ?? false;
  @override
  bool get isCameraEnabled => _room.localParticipant?.isCameraEnabled() ?? false;

  RemoteParticipant? get _remote => _room.remoteParticipants.values.firstOrNull;

  VideoTrack? get _remoteTrack {
    final pubs = _remote?.videoTrackPublications ?? const [];
    for (final p in pubs) {
      final t = p.track;
      if (t != null && p.subscribed && !p.muted) return t;
    }
    return null;
  }

  VideoTrack? get _localTrack {
    final pubs = _room.localParticipant?.videoTrackPublications ?? const [];
    for (final p in pubs) {
      if (p.track != null && !p.muted) return p.track;
    }
    return null;
  }

  @override
  bool get hasRemoteVideo => _remoteTrack != null;

  @override
  Future<void> connect({required String url, required String token, required bool video}) async {
    _link.add(LinkState.connecting);
    try {
      await _room.connect(url, token);
      await _room.localParticipant?.setMicrophoneEnabled(true);
      if (video) await _room.localParticipant?.setCameraEnabled(true);
      _link.add(LinkState.connected);
      _notify();
    } catch (e) {
      _link.add(LinkState.disconnected);
      throw Failure(FailureType.network, debugDetail: 'livekit connect: ${e.runtimeType}');
    }
  }

  @override
  Future<void> setMicEnabled(bool enabled) async {
    await _room.localParticipant?.setMicrophoneEnabled(enabled);
    _notify();
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    await _room.localParticipant?.setCameraEnabled(enabled);
    _notify();
  }

  @override
  Future<void> switchCamera() async {
    for (final p in _room.localParticipant?.videoTrackPublications ?? const <LocalTrackPublication<LocalVideoTrack>>[]) {
      final t = p.track;
      if (t is LocalVideoTrack) {
        _front = !_front;
        await t.setCameraPosition(_front ? CameraPosition.front : CameraPosition.back);
      }
    }
  }

  @override
  Future<void> sendChat(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _room.localParticipant?.publishData(utf8.encode(jsonEncode({'id': id, 'text': t})), reliable: true, topic: 'chat');
    _chat.add(CallChatMessage(id: id, fromMe: true, text: t, timestamp: DateTime.now()));
  }

  @override
  Future<void> disconnect() async {
    try {
      await _room.disconnect();
    } catch (_) {}
  }

  @override
  Widget? remoteView() {
    final t = _remoteTrack;
    return t == null ? null : VideoTrackRenderer(t, fit: VideoViewFit.cover);
  }

  @override
  Widget? localView() {
    final t = _localTrack;
    return t == null ? null : VideoTrackRenderer(t, fit: VideoViewFit.cover, mirrorMode: _front ? VideoViewMirrorMode.mirror : VideoViewMirrorMode.off);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _room.removeListener(_notify);
    await _listener.dispose();
    await disconnect();
    await _room.dispose();
    await _link.close();
    await _chat.close();
    await _remoteEnded.close();
    await _changes.close();
  }
}
