import 'package:flutter/widgets.dart';

import 'interpreter_models.dart';

enum LinkState { disconnected, connecting, connected, reconnecting }

/// Real-time media session (LiveKit today). Kept abstract so the transport can
/// change or scale independently of the UI.
abstract class CallService {
  Stream<LinkState> get linkState;
  Stream<CallChatMessage> get chatMessages;

  /// Fires when the remote side leaves / the room closes.
  Stream<void> get remoteEnded;

  bool get isMicEnabled;
  bool get isCameraEnabled;
  bool get hasRemoteVideo;

  Future<void> connect({required String url, required String token, required bool video});
  Future<void> setMicEnabled(bool enabled);
  Future<void> setCameraEnabled(bool enabled);
  Future<void> switchCamera();
  Future<void> sendChat(String text);
  Future<void> disconnect();

  /// Video widgets (null until a track exists).
  Widget? remoteView();
  Widget? localView();

  /// Notifies when tracks/participants change so the UI can rebuild.
  Stream<void> get changes;

  Future<void> dispose();
}
