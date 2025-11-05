import '../../../../core/util/result.dart';
import '../entities/user.dart';
import '../value_objects/email.dart';
import '../value_objects/token.dart';

abstract class AuthRepository {
  Future<Result<User>> signIn(Email email, String password);
  Future<Result<Token>> refreshToken(String refreshToken);
  Future<Result<void>> signOut();
  Future<Result<User?>> getCurrentUser();
}


