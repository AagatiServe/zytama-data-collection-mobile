import '../../data/models/dashboard_model.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository _repo;
  GetDashboardUseCase(this._repo);

  Future<DashboardPageModel> call({
    int limit = 20,
    String? cursor,
    String? search,
    String? status,
  }) =>
      _repo.getDashboard(
        limit: limit,
        cursor: cursor,
        search: search,
        status: status,
      );
}
