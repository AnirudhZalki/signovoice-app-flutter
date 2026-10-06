import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'failure.dart';

/// Converts any thrown object into a [Failure] without leaking its message.
Failure toFailure(Object error) {
  if (error is Failure) return error;
  if (error is TimeoutException) {
    return Failure(FailureType.timeout, debugDetail: error.toString());
  }
  if (error is SocketException) {
    return Failure(FailureType.offline, debugDetail: error.message);
  }
  if (error is DioException) return _fromDio(error);
  if (error is FirebaseAuthException) return _fromFirebaseAuth(error);
  if (error is FirebaseException) {
    return switch (error.code) {
      'unavailable' => Failure(FailureType.network, code: error.code),
      'permission-denied' => Failure(FailureType.unauthorized, code: error.code),
      'not-found' => Failure(FailureType.notFound, code: error.code),
      _ => Failure(FailureType.unknown, code: error.code),
    };
  }
  return Failure(FailureType.unknown, debugDetail: error.runtimeType.toString());
}

Failure _fromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Failure(FailureType.timeout, debugDetail: e.type.name);
    case DioExceptionType.connectionError:
      return Failure(FailureType.offline, debugDetail: e.type.name);
    case DioExceptionType.cancel:
      return const Failure(FailureType.cancelled);
    default:
      final s = e.response?.statusCode ?? 0;
      final why = _serverReason(e.response?.data);
      if (s == 401 || s == 403) return Failure(FailureType.unauthorized, code: '$s', debugDetail: why);
      if (s == 404) return Failure(FailureType.notFound, code: '$s', debugDetail: why);
      if (s == 429) return Failure(FailureType.limitReached, code: '$s', debugDetail: why);
      if (s >= 500) return Failure(FailureType.serviceUnavailable, code: '$s', debugDetail: why);
      return Failure(FailureType.unknown, code: '$s', debugDetail: why);
  }
}

/// Short reason the SignoVoice backend put in its JSON error body (`detail`, else `error`); never secrets.
String? _serverReason(Object? data) {
  if (data is! Map) return null;
  final parts = [for (final k in const ['error', 'detail']) if (data[k] is String && (data[k] as String).isNotEmpty) data[k] as String];
  if (parts.isEmpty) return null;
  final text = parts.join(' — ');
  return text.length > 160 ? text.substring(0, 160) : text;
}

Failure _fromFirebaseAuth(FirebaseAuthException e) {
  return switch (e.code) {
    'network-request-failed' => Failure(FailureType.network, code: e.code),
    'requires-recent-login' =>
      Failure(FailureType.requiresRecentLogin, code: e.code),
    'user-disabled' ||
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-verification-code' ||
    'invalid-verification-id' ||
    'email-already-in-use' ||
    'weak-password' ||
    'invalid-email' ||
    'invalid-phone-number' ||
    'too-many-requests' ||
    'credential-already-in-use' ||
    'account-exists-with-different-credential' =>
      Failure(FailureType.validation, code: e.code),
    'operation-not-allowed' ||
    'app-not-authorized' =>
      Failure(FailureType.notConfigured, code: e.code),
    _ => Failure(FailureType.unknown, code: e.code),
  };
}
