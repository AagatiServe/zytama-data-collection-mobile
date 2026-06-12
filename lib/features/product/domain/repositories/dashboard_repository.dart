import '../../data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardPageModel> getDashboard({
    int limit = 20,
    String? cursor,
    String? search,
    String? status,
  });
}
