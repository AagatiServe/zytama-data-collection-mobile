import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  AuthRepositoryImpl(this.remoteDataSource, this.prefs);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final model = await remoteDataSource.login(email, password);
      await prefs.setString(AppConstants.tokenKey, model.token);
      await prefs.setString(AppConstants.userNameKey, model.name);
      await prefs.setString(AppConstants.userEmailKey, model.email);
      await prefs.setString(AppConstants.agentCodeKey, model.agentCode);
      return Right(UserEntity(
        email: model.email,
        name: model.name,
        token: model.token,
        agentCode: model.agentCode,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserEntity?> getStoredUser() async {
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null || token.isEmpty) return null;
    return UserEntity(
      token: token,
      name: prefs.getString(AppConstants.userNameKey) ?? '',
      email: prefs.getString(AppConstants.userEmailKey) ?? '',
      agentCode: prefs.getString(AppConstants.agentCodeKey) ?? '',
    );
  }

  @override
  Future<void> logout() async {
    await prefs.clear();
  }
}
