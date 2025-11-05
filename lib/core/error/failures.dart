import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const Failure._();

  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  const factory Failure.timeout({
    required String message,
  }) = TimeoutFailure;

  const factory Failure.auth({
    required String message,
  }) = AuthFailure;

  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  const factory Failure.unknown({
    required String message,
    Object? error,
  }) = UnknownFailure;

  String get message => when(
        server: (msg, _) => msg,
        network: (msg) => msg,
        timeout: (msg) => msg,
        auth: (msg) => msg,
        cache: (msg) => msg,
        unknown: (msg, _) => msg,
      );
}
