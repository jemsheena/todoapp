import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/util/result.dart';
import '../../../../core/error/failures.dart';
import '../dtos/user_dto.dart';
import '../dtos/token_dto.dart';

abstract class AuthRemoteDataSource {
  Future<Result<TokenDto>> signIn(String email, String password);
  Future<Result<TokenDto>> refreshToken(String refreshToken);
  Future<Result<UserDto>> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Result<TokenDto>> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );

      final tokenDto = TokenDto.fromJson(response.data);
      return Right(tokenDto);
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(
        Failure.unknown(message: e.toString(), error: e),
      );
    }
  }

  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final tokenDto = TokenDto.fromJson(response.data);
      return Right(tokenDto);
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(
        Failure.unknown(message: e.toString(), error: e),
      );
    }
  }

  @override
  Future<Result<UserDto>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      final userDto = UserDto.fromJson(response.data);
      return Right(userDto);
    } on DioException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(
        Failure.unknown(message: e.toString(), error: e),
      );
    }
  }
}

