import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardPageModel>> getDashboard({
    int limit = 20,
    String? cursor,
    String? search,
    String? status,
  });
}
