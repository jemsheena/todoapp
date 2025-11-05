import 'package:dartz/dartz.dart';
import '../../../../core/util/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/email.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  Future<Result<User>> call(Email email, String password) async {
    final emailError = email.validationError;
    if (emailError != null) {
      return const Left(
        Failure.unknown(message: 'Invalid email format'),
      );
    }

    if (password.isEmpty) {
      return const Left(
        Failure.unknown(message: 'Password is required'),
      );
    }

    return await _repository.signIn(email, password);
  }
}
