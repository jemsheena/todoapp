import 'dart:developer' as developer;
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorHandler {
  static Future<void> logError(dynamic error, StackTrace? stack) async {
    developer.log(
      'Error: $error',
      name: 'ErrorHandler',
      error: error,
      stackTrace: stack,
    );

    // Report to Sentry in production
    if (!const bool.fromEnvironment('dart.vm.product')) {
      await Sentry.captureException(
        error,
        stackTrace: stack,
      );
    }
  }
}


