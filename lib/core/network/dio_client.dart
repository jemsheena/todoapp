import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../env/app_config.dart';
import '../error/failures.dart';
import 'dio_interceptors.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add request ID interceptor
  dio.interceptors.add(RequestIdInterceptor());

  // Add auth interceptor (TODO: inject token)
  dio.interceptors.add(AuthInterceptor());

  // Add logging (debug only)
  if (config.enableLogging) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
  }

  // Add retry interceptor
  dio.interceptors.add(RetryInterceptor());

  return dio;
});

class RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-ID'] = DateTime.now().millisecondsSinceEpoch.toString();
    super.onRequest(options, handler);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Get token from secure storage
    // final token = await getToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    super.onRequest(options, handler);
  }
}

class RetryInterceptor extends Interceptor {
  static const maxRetries = 3;
  static const baseDelay = Duration(milliseconds: 500);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

      if (retryCount < maxRetries) {
        await Future.delayed(baseDelay * (1 << retryCount)); // Exponential backoff

        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

extension DioExceptionExtension on DioException {
  Failure toFailure() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure.timeout(message: 'Request timeout');
      case DioExceptionType.badResponse:
        final statusCode = response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const Failure.auth(message: 'Authentication failed');
        }
        return Failure.server(
          message: response?.statusMessage ?? 'Server error',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const Failure.network(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return const Failure.network(message: 'No internet connection');
      default:
        return Failure.unknown(
          message: message ?? 'Unknown error occurred',
          error: error,
        );
    }
  }
}


