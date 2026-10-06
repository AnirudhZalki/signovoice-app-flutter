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
    this.ratePaise = 0,
    this.sessionMinutes = 30,
    this.bio = '',
  });

  final String id;
  final String name;
  final List<String> languages;
  final double? rating;
  final int ratingCount;
  final InterpreterStatus status;
  final String? photoUrl;

  /// Price of one session in paise (0 = free).
  final int ratePaise;
  final int sessionMinutes;
  final String bio;

  bool get isAvailable => status == InterpreterStatus.available;

  factory Interpreter.fromJson(Map<String, dynamic> j) => Interpreter(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        languages: (j['languages'] as List<dynamic>? ?? const []).cast<String>(),
        rating: (j['rating'] as num?)?.toDouble(),
        ratingCount: j['ratingCount'] as int? ?? 0,
        status: InterpreterStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => InterpreterStatus.offline),
        photoUrl: j['photoUrl'] as String?,
        ratePaise: (j['ratePaise'] as num?)?.toInt() ?? 0,
        sessionMinutes: (j['sessionMinutes'] as num?)?.toInt() ?? 30,
        bio: j['bio'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, name, languages, rating, ratingCount, status, photoUrl, ratePaise, sessionMinutes, bio];
}

enum RequestStatus { awaitingPayment, waiting, accepted, declined, expired, cancelled }

RequestStatus parseRequestStatus(Object? v) => v == 'awaiting_payment'
    ? RequestStatus.awaitingPayment
    : RequestStatus.values.firstWhere((s) => s.name == v, orElse: () => RequestStatus.waiting);

/// A Razorpay order the backend created for a paid request (the key *secret* never reaches the app).
class PaymentOrder extends Equatable {
  const PaymentOrder({required this.orderId, required this.amountPaise, required this.currency, required this.keyId});
  final String orderId;
  final int amountPaise;
  final String currency;
  final String keyId;

  factory PaymentOrder.fromJson(Map<String, dynamic> j) => PaymentOrder(
        orderId: j['order_id'] as String,
        amountPaise: (j['amount'] as num).toInt(),
        currency: j['currency'] as String? ?? 'INR',
        keyId: j['keyId'] as String,
      );

  @override
  List<Object?> get props => [orderId, amountPaise, currency, keyId];
}

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
  const CallRequestState({required this.requestId, required this.status, this.session, this.queuePosition, this.order});

  final String requestId;
  final RequestStatus status;
  final CallSession? session;
  final int? queuePosition;

  /// Present when [status] is [RequestStatus.awaitingPayment].
  final PaymentOrder? order;

  factory CallRequestState.fromJson(Map<String, dynamic> j, {String? fallbackId}) => CallRequestState(
        requestId: (j['requestId'] as String?) ?? fallbackId ?? '',
        status: parseRequestStatus(j['status']),
        order: j['order'] is Map<String, dynamic> ? PaymentOrder.fromJson(j['order'] as Map<String, dynamic>) : null,
        session: j['session'] is Map<String, dynamic> ? CallSession.fromJson(j['session'] as Map<String, dynamic>) : null,
        queuePosition: j['position'] as int?,
      );

  @override
  List<Object?> get props => [requestId, status, session, queuePosition, order];
}

/// The signed-in person's interpreter profile (approved interpreters see the desk).
class InterpreterMe extends Equatable {
  const InterpreterMe({
    required this.approved,
    this.applied = false,
    this.status = InterpreterStatus.offline,
    this.name = '',
    this.languages = const [],
    this.ratePaise = 0,
    this.bio = '',
    this.earningsPaise = 0,
  });
  final bool approved;

  /// Has submitted a profile (waiting for approval when [approved] is false).
  final bool applied;
  final InterpreterStatus status;
  final String name;
  final List<String> languages;
  final int ratePaise;
  final String bio;
  final int earningsPaise;

  factory InterpreterMe.fromJson(Map<String, dynamic> j) => InterpreterMe(
        approved: j['approved'] == true,
        applied: j['applied'] == true || j['approved'] == true,
        status: InterpreterStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => InterpreterStatus.offline),
        name: j['name'] as String? ?? '',
        languages: (j['languages'] as List<dynamic>? ?? const []).cast<String>(),
        ratePaise: (j['ratePaise'] as num?)?.toInt() ?? 0,
        bio: j['bio'] as String? ?? '',
        earningsPaise: (j['earningsPaise'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [approved, applied, status, name, languages, ratePaise, bio, earningsPaise];
}

/// An interpreter application as seen by an admin.
class AdminInterpreter extends Equatable {
  const AdminInterpreter({required this.uid, required this.name, this.email = '', this.languages = const [], this.ratePaise = 0, this.bio = '', this.approved = false, this.earningsPaise = 0});
  final String uid;
  final String name;
  final String email;
  final List<String> languages;
  final int ratePaise;
  final String bio;
  final bool approved;
  final int earningsPaise;

  factory AdminInterpreter.fromJson(Map<String, dynamic> j) => AdminInterpreter(
        uid: j['uid'] as String,
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        languages: (j['languages'] as List<dynamic>? ?? const []).cast<String>(),
        ratePaise: (j['ratePaise'] as num?)?.toInt() ?? 0,
        bio: j['bio'] as String? ?? '',
        approved: j['approved'] == true,
        earningsPaise: (j['earningsPaise'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [uid, name, email, languages, ratePaise, bio, approved, earningsPaise];
}

/// A waiting request shown in the interpreter's queue.
class IncomingRequest extends Equatable {
  const IncomingRequest({required this.requestId, required this.name, required this.mode, required this.language, this.note, this.waitingSeconds = 0, this.amountPaise = 0, this.earnPaise = 0, this.directed = false});
  final String requestId;
  final String name;
  final CallMode mode;
  final String language;
  final String? note;
  final int waitingSeconds;

  /// What the person paid / what this interpreter earns from it (after the platform fee), in paise.
  final int amountPaise;
  final int earnPaise;

  /// Addressed to this interpreter specifically (can be declined).
  final bool directed;

  factory IncomingRequest.fromJson(Map<String, dynamic> j) => IncomingRequest(
        requestId: j['requestId'] as String,
        name: j['name'] as String? ?? '',
        mode: j['mode'] == 'audio' ? CallMode.audio : CallMode.video,
        language: j['language'] as String? ?? '',
        note: (j['note'] as String?)?.isEmpty ?? true ? null : j['note'] as String,
        waitingSeconds: (j['waitingSeconds'] as num?)?.toInt() ?? 0,
        amountPaise: (j['amountPaise'] as num?)?.toInt() ?? 0,
        earnPaise: (j['earnPaise'] as num?)?.toInt() ?? 0,
        directed: j['directed'] == true,
      );

  @override
  List<Object?> get props => [requestId, name, mode, language, note, waitingSeconds, amountPaise, earnPaise, directed];
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
