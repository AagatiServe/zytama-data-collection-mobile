import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<bool> isLoggedIn();
  Future<UserEntity?> getStoredUser();
  Future<void> logout();
}
