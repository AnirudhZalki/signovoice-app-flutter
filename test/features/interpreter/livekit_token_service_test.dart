import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/features/interpreter/data/livekit_token_service.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final ResponseBody Function(RequestOptions) handler;
  final calls = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    calls.add('${o.method} ${o.uri}');
    return handler(o);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int code) => ResponseBody.fromString(jsonEncode(body), code, headers: {
      Headers.contentTypeHeader: ['application/json']
    });

void main() {
  const url = 'https://tokens.example.com/token';

  test('parses token + url from JSON, accepts alternate key names and a bare JWT', () {
    final a = LiveKitTokenService.parseTokenResponse('{"token":"a.b.c","url":"wss://x.livekit.cloud"}', 'r1');
    expect((a.token, a.url, a.roomName), ('a.b.c', 'wss://x.livekit.cloud', 'r1'));
    expect(LiveKitTokenService.parseTokenResponse('{"accessToken":"t"}', 'r').token, 't');
    expect(LiveKitTokenService.parseTokenResponse('aaa.bbb.ccc', 'r').token, 'aaa.bbb.ccc');
    expect(() => LiveKitTokenService.parseTokenResponse('{"nope":1}', 'r'), throwsA(isA<Failure>()));
    expect(() => LiveKitTokenService.parseTokenResponse('<html>', 'r'), throwsA(isA<Failure>()));
  });

  test('POST first, falls back to GET when the server only allows GET', () async {
    final adapter = _Adapter((o) => o.method == 'POST' ? _json({'error': 'no'}, 405) : _json({'token': 'x.y.z'}, 200));
    final dio = Dio()..httpClientAdapter = adapter;
    final s = await LiveKitTokenService(dio: dio, url: url).fetch(room: 'abc', identity: 'u1');
    expect(s.token, 'x.y.z');
    expect(adapter.calls.first, startsWith('POST'));
    expect(adapter.calls.last, contains('GET https://tokens.example.com/token?room=abc'));
  });

  test('server errors become failures, never a session', () async {
    final dio = Dio()..httpClientAdapter = _Adapter((o) => _json({'error': 'boom'}, 500));
    expect(LiveKitTokenService(dio: dio, url: url).fetch(room: 'abc', identity: 'u1'), throwsA(isA<Failure>()));
  });
}
