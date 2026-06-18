import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(SharedPreferences prefs) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor(prefs));
    _dio.interceptors.add(_CurlInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> postMultipart(String path, FormData formData) =>
      _dio.post(path, data: formData);
}

// ── Auth interceptor ──────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  _AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

// ── Curl log interceptor ──────────────────────────────────────────────────────

class _CurlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _printCurl(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _printResponse(err.response!);
    } else {
      dev.log('[API ERROR] ${err.message}', name: 'ApiClient');
    }
    handler.next(err);
  }

  void _printCurl(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write('curl -X ${options.method} \'${options.uri}\'');

    // Headers
    options.headers.forEach((key, value) {
      // Truncate long auth tokens for readability
      final display = key == 'Authorization' && value is String && value.length > 40
          ? '${value.substring(0, 40)}...'
          : value;
      buffer.write(" \\\n  -H '$key: $display'");
    });

    // Body
    final data = options.data;
    if (data != null && data is! FormData) {
      try {
        final encoded = jsonEncode(data);
        buffer.write(" \\\n  -d '$encoded'");
      } catch (_) {
        buffer.write(" \\\n  -d '$data'");
      }
    } else if (data is FormData) {
      for (final field in data.fields) {
        buffer.write(" \\\n  -F '${field.key}=${field.value}'");
      }
      for (final file in data.files) {
        buffer.write(" \\\n  -F '${file.key}=@${file.value.filename}'");
      }
    }

    dev.log('\n$buffer\n', name: 'API ▶');
  }

  void _printResponse(Response response) {
    final status = response.statusCode;
    final uri = response.requestOptions.uri;
    String body;
    try {
      body = const JsonEncoder.withIndent('  ').convert(response.data);
    } catch (_) {
      body = response.data.toString();
    }
    dev.log('[$status] $uri\n$body\n', name: 'API ◀');
  }
}
