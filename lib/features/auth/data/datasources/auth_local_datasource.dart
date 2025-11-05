import 'package:dartz/dartz.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/util/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/value_objects/token.dart';
import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<Result<void>> saveToken(Token token);
  Future<Result<Token?>> getToken();
  Future<Result<void>> saveUser(User user);
  Future<Result<User?>> getUser();
  Future<Result<void>> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  static const _keyUser = 'auth_user';

  @override
  Future<Result<void>> saveToken(Token token) async {
    try {
      await _secureStorage.saveToken(token.accessToken);
      await _secureStorage.saveRefreshToken(token.refreshToken);
      return const Right(null);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to save token: $e'),
      );
    }
  }

  @override
  Future<Result<Token?>> getToken() async {
    try {
      final accessToken = await _secureStorage.getToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        return const Right(null);
      }

      // TODO: Get expiresAt from storage or JWT decode
      final token = Token(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      return Right(token);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to get token: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveUser(User user) async {
    try {
      final userJson = UserDto(
        id: user.id,
        email: user.email,
        name: user.name,
        avatarUrl: user.avatarUrl,
        isVerified: user.isVerified,
      ).toJson();
      await _prefs.setString(_keyUser, userJson.toString());
      return const Right(null);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to save user: $e'),
      );
    }
  }

  @override
  Future<Result<User?>> getUser() async {
    try {
      final userJsonStr = _prefs.getString(_keyUser);
      if (userJsonStr == null) {
        return const Right(null);
      }

      // TODO: Parse JSON properly
      // For now, return null
      return const Right(null);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to get user: $e'),
      );
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      await _secureStorage.clearAll();
      await _prefs.remove(_keyUser);
      return const Right(null);
    } catch (e) {
      return Left(
        Failure.cache(message: 'Failed to clear: $e'),
      );
    }
  }
}

