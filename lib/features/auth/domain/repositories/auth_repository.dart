import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<bool> isLoggedIn();
  Future<UserEntity?> getStoredUser();
  Future<void> logout();
}
