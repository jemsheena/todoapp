import 'package:dartz/dartz.dart';
import '../../../../core/util/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/token.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../dtos/token_dto.dart';
import '../dtos/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<User>> signIn(Email email, String password) async {
    final tokenResult = await _remoteDataSource.signIn(email.value, password);

    return tokenResult.fold(
      (failure) => Left(failure),
      (tokenDto) async {
        final token = tokenDto.toDomain();
        final saveTokenResult = await _localDataSource.saveToken(token);

        if (saveTokenResult.isFailure) {
          return Left(saveTokenResult.failure!);
        }

        final userResult = await _remoteDataSource.getCurrentUser();

        return userResult.fold(
          (failure) => Left(failure),
          (userDto) async {
            final user = userDto.toDomain();
            await _localDataSource.saveUser(user);
            return Right(user);
          },
        );
      },
    );
  }

  @override
  Future<Result<Token>> refreshToken(String refreshToken) async {
    final tokenResult =
        await _remoteDataSource.refreshToken(refreshToken);

    return tokenResult.fold(
      (failure) => Left(failure),
      (tokenDto) async {
        final token = tokenDto.toDomain();
        final saveResult = await _localDataSource.saveToken(token);

        return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right(token),
        );
      },
    );
  }

  @override
  Future<Result<void>> signOut() async {
    return await _localDataSource.clearAll();
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    // First try local
    final localUserResult = await _localDataSource.getUser();
    if (localUserResult.isSuccess && localUserResult.value != null) {
      return localUserResult;
    }

    // Then try remote
    final remoteResult = await _remoteDataSource.getCurrentUser();
    return remoteResult.fold(
      (failure) => Left(failure),
      (userDto) async {
        final user = userDto.toDomain();
        await _localDataSource.saveUser(user);
        return Right(user);
      },
    );
  }
}

