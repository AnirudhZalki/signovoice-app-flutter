import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../core/services/api_client.dart' show TokenProvider;
import '../domain/interpreter_models.dart';

/// Gets a LiveKit access token for a room from a standalone token server (the API *secret* stays on
/// that server). Tolerant of the common shapes so the server can stay as it is:
///  - `POST {url}` with JSON `{roomId, room, roomName, identity, name}`; on 404/405 falls back to `GET {url}?room=&identity=&name=`
///  - response JSON with `token` (or `accessToken` / `jwt`) and optionally `url` / `serverUrl` / `wsUrl`, or a bare JWT string.
class LiveKitTokenService {
  LiveKitTokenService({Dio? dio, String? url, TokenProvider? authToken})
      : _dio = dio ?? Dio(),
        _url = url ?? AppConfig.livekitTokenUrl,
        _auth = authToken;

  final Dio _dio;
  final String _url;
  final TokenProvider? _auth;

  // Render's free tier sleeps and can take ~a minute to wake: be patient on the first call.
  static const _patience = Duration(seconds: 75);

  Future<CallSession> fetch({required String room, required String identity, String? name}) async {
    final headers = <String, dynamic>{'Accept': 'application/json'};
    final auth = await _auth?.call();
    if (auth != null) headers['Authorization'] = 'Bearer $auth';
    final options = Options(headers: headers, connectTimeout: _patience, receiveTimeout: _patience, sendTimeout: _patience, responseType: ResponseType.plain);
    // `roomId` is what the SignoVoice token server (SignoVoice-livekkit-server) requires; the others are for other servers.
    final body = {'roomId': room, 'room': room, 'roomName': room, 'identity': identity, 'name': name ?? identity};

    try {
      Response<String> res;
      try {
        res = await _dio.post<String>(_url, data: body, options: options);
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        if (code != 404 && code != 405) rethrow;
        res = await _dio.get<String>(_url, queryParameters: body, options: options);
      }
      return parseTokenResponse(res.data ?? '', room);
    } on Failure {
      rethrow;
    } catch (e) {
      throw toFailure(e);
    }
  }

  static CallSession parseTokenResponse(String raw, String room) {
    final text = raw.trim();
    String? token;
    String? url;
    if (text.startsWith('{')) {
      final j = _decode(text);
      token = (j['token'] ?? j['accessToken'] ?? j['jwt'] ?? j['access_token']) as String?;
      url = (j['url'] ?? j['serverUrl'] ?? j['wsUrl'] ?? j['livekitUrl']) as String?;
    } else if (text.split('.').length == 3) {
      token = text.replaceAll('"', '');
    }
    if (token == null || token.isEmpty) {
      throw const Failure(FailureType.serviceUnavailable, debugDetail: 'token server returned no token');
    }
    return CallSession(callId: 'dev', token: token, roomName: room, url: (url != null && url.startsWith('wss://')) ? url : null);
  }

  static Map<String, dynamic> _decode(String s) {
    try {
      return Map<String, dynamic>.from(jsonDecode(s) as Map);
    } catch (_) {
      throw const Failure(FailureType.serviceUnavailable, debugDetail: 'token server returned invalid JSON');
    }
  }
}
