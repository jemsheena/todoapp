import 'package:dartz/dartz.dart';
import '../error/failures.dart';

typedef Result<T> = Either<Failure, T>;

extension ResultExtension<T> on Result<T> {
  T? get value => fold((l) => null, (r) => r);
  Failure? get failure => fold((l) => l, (r) => null);
  bool get isSuccess => isRight();
  bool get isFailure => isLeft();
}


