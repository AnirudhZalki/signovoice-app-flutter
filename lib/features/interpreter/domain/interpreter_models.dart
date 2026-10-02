import 'package:equatable/equatable.dart';

enum InterpreterStatus { available, busy, offline }

enum CallMode { video, audio }

class Interpreter extends Equatable {
  const Interpreter({
    required this.id,
    required this.name,
    this.languages = const [],
    this.rating,
    this.ratingCount = 0,
    this.status = InterpreterStatus.offline,
    this.photoUrl,
  });

  final String id;
  final String name;
  final List<String> languages;
  final double? rating;
  final int ratingCount;
  final InterpreterStatus status;
  final String? photoUrl;

  bool get isAvailable => status == InterpreterStatus.available;

  factory Interpreter.fromJson(Map<String, dynamic> j) => Interpreter(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        languages: (j['languages'] as List<dynamic>? ?? const []).cast<String>(),
        rating: (j['rating'] as num?)?.toDouble(),
        ratingCount: j['ratingCount'] as int? ?? 0,
        status: InterpreterStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => InterpreterStatus.offline),
        photoUrl: j['photoUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, name, languages, rating, ratingCount, status, photoUrl];
}

enum RequestStatus { waiting, accepted, declined, expired, cancelled }

/// Connection details returned once an interpreter accepts.
class CallSession extends Equatable {
  const CallSession({required this.callId, required this.token, required this.roomName, this.url, this.interpreterName});

  final String callId;
  final String token;
  final String roomName;

  /// LiveKit URL from the backend; falls back to `LIVEKIT_URL` build config.
  final String? url;
  final String? interpreterName;

  factory CallSession.fromJson(Map<String, dynamic> j) => CallSession(
        callId: j['callId'] as String,
        token: j['token'] as String,
        roomName: j['roomName'] as String? ?? '',
        url: j['url'] as String?,
        interpreterName: j['interpreterName'] as String?,
      );

  @override
  List<Object?> get props => [callId, token, roomName, url, interpreterName];
}

class CallRequestState extends Equatable {
  const CallRequestState({required this.requestId, required this.status, this.session, this.queuePosition});

  final String requestId;
  final RequestStatus status;
  final CallSession? session;
  final int? queuePosition;

  factory CallRequestState.fromJson(Map<String, dynamic> j, {String? fallbackId}) => CallRequestState(
        requestId: (j['requestId'] as String?) ?? fallbackId ?? '',
        status: RequestStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => RequestStatus.waiting),
        session: j['session'] is Map<String, dynamic> ? CallSession.fromJson(j['session'] as Map<String, dynamic>) : null,
        queuePosition: j['position'] as int?,
      );

  @override
  List<Object?> get props => [requestId, status, session, queuePosition];
}

/// The signed-in person's interpreter profile (approved interpreters see the desk).
class InterpreterMe extends Equatable {
  const InterpreterMe({required this.approved, this.status = InterpreterStatus.offline, this.name = ''});
  final bool approved;
  final InterpreterStatus status;
  final String name;

  factory InterpreterMe.fromJson(Map<String, dynamic> j) => InterpreterMe(
        approved: j['approved'] == true,
        status: InterpreterStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => InterpreterStatus.offline),
        name: j['name'] as String? ?? '',
      );

  @override
  List<Object?> get props => [approved, status, name];
}

/// A waiting request shown in the interpreter's queue.
class IncomingRequest extends Equatable {
  const IncomingRequest({required this.requestId, required this.name, required this.mode, required this.language, this.note, this.waitingSeconds = 0});
  final String requestId;
  final String name;
  final CallMode mode;
  final String language;
  final String? note;
  final int waitingSeconds;

  factory IncomingRequest.fromJson(Map<String, dynamic> j) => IncomingRequest(
        requestId: j['requestId'] as String,
        name: j['name'] as String? ?? '',
        mode: j['mode'] == 'audio' ? CallMode.audio : CallMode.video,
        language: j['language'] as String? ?? '',
        note: (j['note'] as String?)?.isEmpty ?? true ? null : j['note'] as String,
        waitingSeconds: (j['waitingSeconds'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [requestId, name, mode, language, note, waitingSeconds];
}

class CallChatMessage extends Equatable {
  const CallChatMessage({required this.id, required this.fromMe, required this.text, required this.timestamp});
  final String id;
  final bool fromMe;
  final String text;
  final DateTime timestamp;
  @override
  List<Object?> get props => [id, fromMe, text, timestamp];
}

enum CallPhase { idle, requesting, waiting, connecting, connected, reconnecting, ended, failed }

enum IssueCategory { audio, video, interpreter, connection, other }
