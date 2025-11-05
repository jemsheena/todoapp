import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String baseUrl;
  final String apiKey;
  final String sentryDsn;
  final String environment;
  final bool enableLogging;

  AppConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.sentryDsn,
    required this.environment,
    required this.enableLogging,
  });

  factory AppConfig.fromEnv(Map<String, String> env) {
    return AppConfig(
      baseUrl: env['BASE_URL'] ?? 'http://localhost:3000',
      apiKey: env['API_KEY'] ?? '',
      sentryDsn: env['SENTRY_DSN'] ?? '',
      environment: env['ENVIRONMENT'] ?? 'dev',
      enableLogging: env['ENABLE_LOGGING'] == 'true',
    );
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden in bootstrap');
});


