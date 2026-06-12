import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remote;
  DashboardRepositoryImpl(this._remote);

  @override
  Future<DashboardPageModel> getDashboard({
    int limit = 20,
    String? cursor,
    String? search,
    String? status,
  }) =>
      _remote.getDashboard(
        limit: limit,
        cursor: cursor,
        search: search,
        status: status,
      );
}
