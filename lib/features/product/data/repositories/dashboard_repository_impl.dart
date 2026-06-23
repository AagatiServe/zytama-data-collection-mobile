import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remote;
  DashboardRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, DashboardPageModel>> getDashboard({
    int limit = 20,
    String? cursor,
    String? search,
    String? status,
  }) async {
    try {
      final result = await _remote.getDashboard(
        limit: limit,
        cursor: cursor,
        search: search,
        status: status,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
