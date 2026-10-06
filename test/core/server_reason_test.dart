import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/errors/failure.dart';
import 'package:signovoice/core/errors/failure_mapper.dart';

DioException _http(int code, Object body) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: code, data: body),
    );

void main() {
  test('HTTP errors keep the status code and the backend\'s short reason', () {
    final f = toFailure(_http(400, {'error': 'amount must be an integer >= 100 paise'}));
    expect((f.type, f.code, f.debugDetail), (FailureType.unknown, '400', 'amount must be an integer >= 100 paise'));
    final g = toFailure(_http(500, {'error': 'server error', 'detail': 'razorpay: The api key provided is invalid'}));
    expect((g.type, g.code), (FailureType.serviceUnavailable, '500'));
    expect(g.debugDetail, 'server error — razorpay: The api key provided is invalid');
    expect(toFailure(_http(502, '<html>')).debugDetail, isNull); // non-JSON bodies are ignored
  });
}
