import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../errors/failure.dart';
import '../errors/failure_mapper.dart';

typedef TokenProvider = Future<String?> Function();

/// Thin HTTPS-only JSON client for the SignoVoice backend. Attaches the
/// current user's ID token; secrets never live in the app.
class ApiClient {
  ApiClient({required TokenProvider tokenProvider, Dio? dio, String? baseUrl})
      : _baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = AppConstants.networkTimeout
      ..receiveTimeout = AppConstants.networkTimeout
      ..sendTimeout = AppConstants.networkTimeout
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) async {
      final token = await tokenProvider();
      if (token != null) o.headers['Authorization'] = 'Bearer $token';
      h.next(o);
    }));
  }

  final Dio _dio;
  final String _baseUrl;

  bool get isConfigured => _baseUrl.startsWith('https://');

  void _ensure() {
    if (!isConfigured) throw const Failure(FailureType.notConfigured, debugDetail: 'API_BASE_URL');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    _ensure();
    try {
      return (await _dio.get<dynamic>(path, queryParameters: query)).data;
    } catch (e) {
      throw toFailure(e);
    }
  }

  Future<dynamic> post(String path, {Object? body}) async {
    _ensure();
    try {
      return (await _dio.post<dynamic>(path, data: body)).data;
    } catch (e) {
      throw toFailure(e);
    }
  }

  Future<dynamic> put(String path, {Object? body}) async {
    _ensure();
    try {
      return (await _dio.put<dynamic>(path, data: body)).data;
    } catch (e) {
      throw toFailure(e);
    }
  }

  Future<dynamic> delete(String path) async {
    _ensure();
    try {
      return (await _dio.delete<dynamic>(path)).data;
    } catch (e) {
      throw toFailure(e);
    }
  }
}
