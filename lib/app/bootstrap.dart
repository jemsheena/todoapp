import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import '../core/env/app_config.dart';
import '../core/error/error_handler.dart';

Future<void> bootstrap() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorHandler.logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.logError(error, stack);
    return true;
  };

  // Load environment
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  await dotenv.load(fileName: _getEnvFile(flavor));

  // Initialize Sentry (only in non-dev or if enabled)
  if (dotenv.get('SENTRY_DSN', fallback: '').isNotEmpty && !kDebugMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dotenv.get('SENTRY_DSN');
        options.environment = flavor;
        options.tracesSampleRate = 0.2;
      },
      appRunner: () => run(),
    );
  } else {
    run();
  }
}

void run() {
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.fromEnv(dotenv.env),
        ),
      ],
      child: const App(),
    ),
  );
}

String _getEnvFile(String flavor) {
  switch (flavor) {
    case 'prod':
      return '.env.prod';
    case 'stage':
      return '.env.stage';
    default:
      return '.env.dev';
  }
}


